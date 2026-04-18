[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Exit-WithUsage {
    param(
        [string]$Message,
        [int]$Code = 2
    )

    if ($Message) {
        Write-Host $Message -ForegroundColor Red
    }

    Write-Host '使い方: powershell -ExecutionPolicy Bypass -File .\check-ks.ps1 <シナリオ.ks>'
    exit $Code
}

function Read-TextFile {
    param([string]$FilePath)

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return [System.Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return [System.Text.Encoding]::BigEndianUnicode.GetString($bytes, 2, $bytes.Length - 2)
    }

    $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        return $utf8Strict.GetString($bytes)
    } catch {
        return [System.Text.Encoding]::GetEncoding(932).GetString($bytes)
    }
}

function Mask-KsComments {
    param(
        [string]$Line,
        [ref]$InBlockComment
    )

    $chars = $Line.ToCharArray()
    $inSingle = $false
    $inDouble = $false
    $escape = $false

    for ($i = 0; $i -lt $chars.Length; $i++) {
        if ($InBlockComment.Value) {
            if ($i + 1 -lt $chars.Length -and $chars[$i] -eq '*' -and $chars[$i + 1] -eq '/') {
                $chars[$i] = ' '
                $chars[$i + 1] = ' '
                $InBlockComment.Value = $false
                $i++
            } else {
                $chars[$i] = ' '
            }
            continue
        }

        $ch = $chars[$i]
        if ($escape) {
            $escape = $false
            continue
        }

        if ($inSingle) {
            if ($ch -eq '\') {
                $escape = $true
            } elseif ($ch -eq "'") {
                $inSingle = $false
            }
            continue
        }

        if ($inDouble) {
            if ($ch -eq '\') {
                $escape = $true
            } elseif ($ch -eq '"') {
                $inDouble = $false
            }
            continue
        }

        if ($i + 1 -lt $chars.Length -and $ch -eq '/' -and $chars[$i + 1] -eq '*') {
            $chars[$i] = ' '
            $chars[$i + 1] = ' '
            $InBlockComment.Value = $true
            $i++
            continue
        }

        if ($ch -eq ';') {
            for ($j = $i; $j -lt $chars.Length; $j++) {
                $chars[$j] = ' '
            }
            break
        }

        if ($ch -eq "'") {
            $inSingle = $true
        } elseif ($ch -eq '"') {
            $inDouble = $true
        }
    }

    return -join $chars
}

function Mask-JsComments {
    param(
        [string]$Line,
        [ref]$InBlockComment
    )

    $chars = $Line.ToCharArray()
    $inSingle = $false
    $inDouble = $false
    $inTemplate = $false
    $escape = $false

    for ($i = 0; $i -lt $chars.Length; $i++) {
        if ($InBlockComment.Value) {
            if ($i + 1 -lt $chars.Length -and $chars[$i] -eq '*' -and $chars[$i + 1] -eq '/') {
                $chars[$i] = ' '
                $chars[$i + 1] = ' '
                $InBlockComment.Value = $false
                $i++
            } else {
                $chars[$i] = ' '
            }
            continue
        }

        $ch = $chars[$i]
        if ($escape) {
            $escape = $false
            continue
        }

        if ($inSingle) {
            if ($ch -eq '\') {
                $escape = $true
            } elseif ($ch -eq "'") {
                $inSingle = $false
            }
            continue
        }

        if ($inDouble) {
            if ($ch -eq '\') {
                $escape = $true
            } elseif ($ch -eq '"') {
                $inDouble = $false
            }
            continue
        }

        if ($inTemplate) {
            if ($ch -eq '\') {
                $escape = $true
            } elseif ($ch -eq '`') {
                $inTemplate = $false
            }
            continue
        }

        if ($i + 1 -lt $chars.Length -and $ch -eq '/' -and $chars[$i + 1] -eq '*') {
            $chars[$i] = ' '
            $chars[$i + 1] = ' '
            $InBlockComment.Value = $true
            $i++
            continue
        }

        if ($i + 1 -lt $chars.Length -and $ch -eq '/' -and $chars[$i + 1] -eq '/') {
            for ($j = $i; $j -lt $chars.Length; $j++) {
                $chars[$j] = ' '
            }
            break
        }

        if ($ch -eq "'") {
            $inSingle = $true
        } elseif ($ch -eq '"') {
            $inDouble = $true
        } elseif ($ch -eq '`') {
            $inTemplate = $true
        }
    }

    return -join $chars
}

function Mask-Strings {
    param([string]$Text)

    $chars = $Text.ToCharArray()
    $inSingle = $false
    $inDouble = $false
    $inTemplate = $false
    $escape = $false

    for ($i = 0; $i -lt $chars.Length; $i++) {
        $ch = $chars[$i]
        if ($escape) {
            $chars[$i] = ' '
            $escape = $false
            continue
        }

        if ($inSingle) {
            $chars[$i] = ' '
            if ($ch -eq '\') {
                $escape = $true
            } elseif ($ch -eq "'") {
                $inSingle = $false
            }
            continue
        }

        if ($inDouble) {
            $chars[$i] = ' '
            if ($ch -eq '\') {
                $escape = $true
            } elseif ($ch -eq '"') {
                $inDouble = $false
            }
            continue
        }

        if ($inTemplate) {
            $chars[$i] = ' '
            if ($ch -eq '\') {
                $escape = $true
            } elseif ($ch -eq '`') {
                $inTemplate = $false
            }
            continue
        }

        if ($ch -eq "'") {
            $chars[$i] = ' '
            $inSingle = $true
        } elseif ($ch -eq '"') {
            $chars[$i] = ' '
            $inDouble = $true
        } elseif ($ch -eq '`') {
            $chars[$i] = ' '
            $inTemplate = $true
        }
    }

    return -join $chars
}

function Get-AssignmentOperators {
    param([string]$Expression)

    $masked = Mask-Strings $Expression
    $results = @()

    for ($i = 0; $i -lt $masked.Length; $i++) {
        if ($masked[$i] -ne '=') { continue }

        $prev = if ($i -gt 0) { $masked[$i - 1] } else { [char]0 }
        $next = if ($i + 1 -lt $masked.Length) { $masked[$i + 1] } else { [char]0 }

        if ($next -eq '=' -or $next -eq '>') { continue }
        if ($prev -eq '=' -or $prev -eq '!' -or $prev -eq '<' -or $prev -eq '>') { continue }

        $start = $i
        $operator = '='
        if ('+-*/%&|^?' -like ('*' + $prev + '*')) {
            $start = $i - 1
            $operator = [string]$prev + '='
            if ($prev -eq '?' -and $start -gt 0 -and $masked[$start - 1] -eq '?') {
                $start--
                $operator = '??='
            } elseif (($prev -eq '&' -or $prev -eq '|') -and $start -gt 0 -and $masked[$start - 1] -eq $prev) {
                $start--
                $operator = [string]$prev + [string]$prev + '='
            }
        }

        $results += [pscustomobject]@{ StartIndex = $start; Operator = $operator }
    }

    return $results
}

function Test-ComparisonLike {
    param([string]$Expression)

    $masked = Mask-Strings $Expression
    if ($masked -match '===|==|!==|!=|<=|>=|&&|\|\|') { return $true }
    if ($masked -match '(?<![<>=!])<(?![<=])|(?<![<>=!])>(?![>=])') { return $true }
    if ($masked -match '(^|[^\w$])![\w$("''`]') { return $true }
    return $false
}

function Split-TopLevel {
    param(
        [string]$Text,
        [char]$Separator
    )

    $parts = @()
    $start = 0
    $depthParen = 0
    $depthBracket = 0
    $depthBrace = 0
    $inSingle = $false
    $inDouble = $false
    $inTemplate = $false
    $escape = $false

    for ($i = 0; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($escape) { $escape = $false; continue }

        if ($inSingle) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq "'") { $inSingle = $false }
            continue
        }
        if ($inDouble) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq '"') { $inDouble = $false }
            continue
        }
        if ($inTemplate) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq '`') { $inTemplate = $false }
            continue
        }

        if ($ch -eq "'") { $inSingle = $true; continue }
        if ($ch -eq '"') { $inDouble = $true; continue }
        if ($ch -eq '`') { $inTemplate = $true; continue }

        if ($ch -eq '(') { $depthParen++; continue }
        if ($ch -eq ')' -and $depthParen -gt 0) { $depthParen--; continue }
        if ($ch -eq '[') { $depthBracket++; continue }
        if ($ch -eq ']' -and $depthBracket -gt 0) { $depthBracket--; continue }
        if ($ch -eq '{') { $depthBrace++; continue }
        if ($ch -eq '}' -and $depthBrace -gt 0) { $depthBrace--; continue }

        if ($ch -eq $Separator -and $depthParen -eq 0 -and $depthBracket -eq 0 -and $depthBrace -eq 0) {
            $parts += [pscustomobject]@{ Text = $Text.Substring($start, $i - $start); StartIndex = $start }
            $start = $i + 1
        }
    }

    $parts += [pscustomobject]@{ Text = $Text.Substring($start); StartIndex = $start }
    return $parts
}

function Get-BalancedParenContent {
    param(
        [string]$Text,
        [int]$OpenIndex
    )

    $depth = 0
    $inSingle = $false
    $inDouble = $false
    $inTemplate = $false
    $escape = $false

    for ($i = $OpenIndex; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($escape) { $escape = $false; continue }

        if ($inSingle) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq "'") { $inSingle = $false }
            continue
        }
        if ($inDouble) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq '"') { $inDouble = $false }
            continue
        }
        if ($inTemplate) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq '`') { $inTemplate = $false }
            continue
        }

        if ($ch -eq "'") { $inSingle = $true; continue }
        if ($ch -eq '"') { $inDouble = $true; continue }
        if ($ch -eq '`') { $inTemplate = $true; continue }

        if ($ch -eq '(') {
            $depth++
            continue
        }
        if ($ch -eq ')') {
            $depth--
            if ($depth -eq 0) {
                return [pscustomobject]@{ Text = $Text.Substring($OpenIndex + 1, $i - $OpenIndex - 1); StartIndex = $OpenIndex + 1 }
            }
        }
    }

    return $null
}

function Get-TernaryCondition {
    param([string]$Text)

    $depthParen = 0
    $depthBracket = 0
    $depthBrace = 0
    $inSingle = $false
    $inDouble = $false
    $inTemplate = $false
    $escape = $false

    for ($i = 0; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($escape) { $escape = $false; continue }

        if ($inSingle) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq "'") { $inSingle = $false }
            continue
        }
        if ($inDouble) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq '"') { $inDouble = $false }
            continue
        }
        if ($inTemplate) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq '`') { $inTemplate = $false }
            continue
        }

        if ($ch -eq "'") { $inSingle = $true; continue }
        if ($ch -eq '"') { $inDouble = $true; continue }
        if ($ch -eq '`') { $inTemplate = $true; continue }

        if ($ch -eq '(') { $depthParen++; continue }
        if ($ch -eq ')' -and $depthParen -gt 0) { $depthParen--; continue }
        if ($ch -eq '[') { $depthBracket++; continue }
        if ($ch -eq ']' -and $depthBracket -gt 0) { $depthBracket--; continue }
        if ($ch -eq '{') { $depthBrace++; continue }
        if ($ch -eq '}' -and $depthBrace -gt 0) { $depthBrace--; continue }

        if ($ch -eq '?' -and $depthParen -eq 0 -and $depthBracket -eq 0 -and $depthBrace -eq 0) {
            if ($i + 1 -lt $Text.Length -and $Text[$i + 1] -eq '.') { continue }

            $prefix = $Text.Substring(0, $i)
            $assignments = @(Get-AssignmentOperators $prefix)
            $start = 0
            if ($assignments.Count -gt 0) {
                $last = $assignments[$assignments.Count - 1]
                $start = $last.StartIndex + $last.Operator.Length
            } elseif ($prefix -match '\breturn\b') {
                $start = $prefix.LastIndexOf('return', [System.StringComparison]::Ordinal) + 6
            }

            $condition = $prefix.Substring($start).Trim()
            if ($condition) {
                $absolute = $prefix.IndexOf($condition, $start, [System.StringComparison]::Ordinal)
                return [pscustomobject]@{ Text = $condition; StartIndex = $absolute }
            }
        }
    }

    return $null
}

function Get-TagsFromLine {
    param([string]$Line)

    $tags = @()
    $inSingle = $false
    $inDouble = $false
    $escape = $false

    for ($i = 0; $i -lt $Line.Length; $i++) {
        $ch = $Line[$i]
        if ($escape) { $escape = $false; continue }

        if ($inSingle) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq "'") { $inSingle = $false }
            continue
        }
        if ($inDouble) {
            if ($ch -eq '\') { $escape = $true } elseif ($ch -eq '"') { $inDouble = $false }
            continue
        }

        if ($ch -eq "'") { $inSingle = $true; continue }
        if ($ch -eq '"') { $inDouble = $true; continue }

        if ($ch -eq '[') {
            $start = $i
            $innerSingle = $false
            $innerDouble = $false
            $innerEscape = $false

            for ($j = $i + 1; $j -lt $Line.Length; $j++) {
                $inner = $Line[$j]
                if ($innerEscape) { $innerEscape = $false; continue }

                if ($innerSingle) {
                    if ($inner -eq '\') { $innerEscape = $true } elseif ($inner -eq "'") { $innerSingle = $false }
                    continue
                }
                if ($innerDouble) {
                    if ($inner -eq '\') { $innerEscape = $true } elseif ($inner -eq '"') { $innerDouble = $false }
                    continue
                }

                if ($inner -eq "'") { $innerSingle = $true; continue }
                if ($inner -eq '"') { $innerDouble = $true; continue }

                if ($inner -eq ']') {
                    $tags += [pscustomobject]@{ Text = $Line.Substring($start, $j - $start + 1); StartIndex = $start }
                    $i = $j
                    break
                }
            }
        }
    }

    if ($Line -match '^\s*@') {
        $index = $Line.IndexOf('@', [System.StringComparison]::Ordinal)
        $tags += [pscustomobject]@{ Text = $Line.Substring($index); StartIndex = $index }
    }

    return $tags
}

function Parse-Tag {
    param([string]$TagText)

    $body = if ($TagText.StartsWith('[')) { $TagText.Substring(1, $TagText.Length - 2) } else { $TagText.Substring(1) }
    $nameMatch = [regex]::Match($body, '^\s*([^\s\]]+)')
    if (-not $nameMatch.Success) { return $null }

    $attributeRegex = [regex]'(?<name>[A-Za-z_][A-Za-z0-9_\-]*)\s*=\s*(?:"(?<dq>(?:[^"\\]|\\.)*)"|''(?<sq>(?:[^''\\]|\\.)*)''|(?<bare>[^\s\]]+))'
    $attributes = @()
    foreach ($match in $attributeRegex.Matches($body)) {
        if ($match.Groups['dq'].Success) {
            $value = $match.Groups['dq'].Value
            $valueIndex = $match.Groups['dq'].Index
        } elseif ($match.Groups['sq'].Success) {
            $value = $match.Groups['sq'].Value
            $valueIndex = $match.Groups['sq'].Index
        } else {
            $value = $match.Groups['bare'].Value
            $valueIndex = $match.Groups['bare'].Index
        }

        $attributes += [pscustomobject]@{
            Name = $match.Groups['name'].Value.ToLowerInvariant()
            Value = $value
            ValueIndex = $valueIndex
        }
    }

    return [pscustomobject]@{ Name = $nameMatch.Groups[1].Value.ToLowerInvariant(); Attributes = $attributes }
}

function New-Problem {
    param(
        [string]$File,
        [int]$Line,
        [int]$Column,
        [string]$Kind,
        [string]$Message,
        [string]$Snippet,
        [string]$Fix
    )

    return [pscustomobject]@{
        File = $File
        Line = $Line
        Column = $Column
        Kind = $Kind
        Message = $Message
        Snippet = $Snippet
        Fix = $Fix
    }
}

function Add-ConditionProblems {
    param(
        [System.Collections.ArrayList]$List,
        [string]$File,
        [int]$Line,
        [int]$ExpressionColumn,
        [string]$Expression,
        [string]$ContextLabel
    )

    foreach ($operator in (Get-AssignmentOperators $Expression)) {
        if ($operator.Operator -eq '=') {
            $message = "$ContextLabel で代入 = が使われています。比較のつもりなら == または === に直してください。"
            $fix = "比較なら: " + $Expression.Substring(0, $operator.StartIndex) + "==" + $Expression.Substring($operator.StartIndex + 1)
        } else {
            $message = "$ContextLabel で代入演算子 $($operator.Operator) が使われています。条件判定の前に別文で代入してから比較してください。"
            $fix = '例: 代入を先に [eval exp="..."] や [iscript] で行い、その結果を cond / exp で比較してください。'
        }

        [void]$List.Add((New-Problem -File $File -Line $Line -Column ($ExpressionColumn + $operator.StartIndex + 1) -Kind '条件式で代入' -Message $message -Snippet $Expression -Fix $fix))
    }
}

function Test-ComparisonOnlyStatement {
    param([string]$Statement)

    $trimmed = $Statement.Trim().TrimEnd(';').Trim()
    if (-not $trimmed) { return $false }
    if ($trimmed -match '^(if|else|while|for|do|switch|case|break|continue|return|throw|var|let|const|function)\b') { return $false }
    if (@(Get-AssignmentOperators $trimmed).Count -gt 0) { return $false }
    if ($trimmed -match '\+\+|--') { return $false }
    return (Test-ComparisonLike $trimmed)
}

function Add-AssignmentContextProblems {
    param(
        [System.Collections.ArrayList]$List,
        [string]$File,
        [int]$Line,
        [int]$ExpressionColumn,
        [string]$Expression,
        [string]$ContextLabel
    )

    foreach ($statement in (Split-TopLevel -Text $Expression -Separator ';')) {
        if (-not (Test-ComparisonOnlyStatement $statement.Text)) { continue }

        $trimmed = $statement.Text.Trim()
        $leading = $statement.Text.Length - $statement.Text.TrimStart().Length
        $match = [regex]::Match($trimmed, '===|==|!==|!=|<=|>=|&&|\|\||(?<![<>=!])<(?![<=])|(?<![<>=!])>(?![>=])')
        $offset = $statement.StartIndex + $leading
        if ($match.Success) { $offset += $match.Index }

        if ($match.Success -and ($match.Value -eq '==' -or $match.Value -eq '===')) {
            $fix = '代入したいなら: ' + $trimmed.Substring(0, $match.Index) + '=' + $trimmed.Substring($match.Index + $match.Value.Length)
        } else {
            $fix = '代入したいなら = を使ってください。判定したいだけなら [if exp="..."] や cond="..." に移してください。'
        }

        $message = $ContextLabel + ' で比較式だけが書かれています。代入のつもりなら = を使ってください。'
        [void]$List.Add((New-Problem -File $File -Line $Line -Column ($ExpressionColumn + $offset + 1) -Kind '代入位置に条件式' -Message $message -Snippet $trimmed -Fix $fix))
    }
}

function Add-ExpressionContextProblems {
    param(
        [System.Collections.ArrayList]$List,
        [string]$File,
        [int]$Line,
        [int]$ExpressionColumn,
        [string]$Expression,
        [string]$ContextLabel
    )

    foreach ($operator in (Get-AssignmentOperators $Expression)) {
        if ($operator.Operator -eq '=') {
            $fix = '比較したいなら: ' + $Expression.Substring(0, $operator.StartIndex) + '==' + $Expression.Substring($operator.StartIndex + 1)
        } else {
            $fix = '副作用のある代入は ' + $ContextLabel + ' ではなく [eval exp="..."] または [iscript] に移してください。'
        }

        $message = $ContextLabel + ' で代入が使われています。表示用の式なら代入せず、比較か参照だけにしてください。'
        [void]$List.Add((New-Problem -File $File -Line $Line -Column ($ExpressionColumn + $operator.StartIndex + 1) -Kind '式評価で代入' -Message $message -Snippet $Expression -Fix $fix))
    }
}

function Add-IscriptProblems {
    param(
        [System.Collections.ArrayList]$List,
        [string]$File,
        [int]$LineNumber,
        [string]$Line
    )

    $masked = Mask-JsComments -Line $Line -InBlockComment ([ref]$script:JsBlockComment)
    if (-not $masked.Trim()) { return }

    $matchedControl = $false
    foreach ($pair in @(
        @{ Name = 'if'; Pattern = '\bif\s*\(' },
        @{ Name = 'else if'; Pattern = '\belse\s+if\s*\(' },
        @{ Name = 'while'; Pattern = '\bwhile\s*\(' },
        @{ Name = 'for'; Pattern = '\bfor\s*\(' }
    )) {
        $match = [regex]::Match($masked, $pair.Pattern)
        if (-not $match.Success) { continue }

        $matchedControl = $true
        $openIndex = $masked.IndexOf('(', $match.Index)
        $paren = Get-BalancedParenContent -Text $masked -OpenIndex $openIndex
        if ($null -eq $paren) { continue }

        if ($pair.Name -eq 'for') {
            $parts = @(Split-TopLevel -Text $paren.Text -Separator ';')
            if ($parts.Count -ge 2) {
                $condition = $parts[1]
                Add-ConditionProblems -List $List -File $File -Line $LineNumber -ExpressionColumn ($paren.StartIndex + $condition.StartIndex) -Expression $condition.Text -ContextLabel '[iscript] の for 条件'
            }
        } else {
            Add-ConditionProblems -List $List -File $File -Line $LineNumber -ExpressionColumn $paren.StartIndex -Expression $paren.Text -ContextLabel ('[iscript] の ' + $pair.Name + ' 条件')
        }
    }

    $ternary = Get-TernaryCondition $masked
    if ($null -ne $ternary) {
        Add-ConditionProblems -List $List -File $File -Line $LineNumber -ExpressionColumn $ternary.StartIndex -Expression $ternary.Text -ContextLabel '[iscript] の三項演算子条件'
    }

    if (-not $matchedControl -and $null -eq $ternary) {
        Add-AssignmentContextProblems -List $List -File $File -Line $LineNumber -ExpressionColumn 0 -Expression $masked -ContextLabel '[iscript] の文'
    }
}

function Write-Problem {
    param([pscustomobject]$Problem)

    Write-Host ($Problem.File + ':' + $Problem.Line + ':' + $Problem.Column + ' [' + $Problem.Kind + '] ' + $Problem.Message) -ForegroundColor Yellow
    Write-Host ('  問題箇所: ' + $Problem.Snippet.Trim())
    Write-Host ('  修正候補: ' + $Problem.Fix) -ForegroundColor Cyan
}

$resolved = Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue
if ($null -eq $resolved) { Exit-WithUsage -Message ('ファイルが見つかりません: ' + $Path) }

$fullPath = $resolved.Path
if (-not [System.IO.File]::Exists($fullPath)) { Exit-WithUsage -Message ('ディレクトリではなく .ks ファイルを指定してください: ' + $Path) }
if ([System.IO.Path]::GetExtension($fullPath).ToLowerInvariant() -ne '.ks') { Exit-WithUsage -Message ('.ks ファイルだけを検査できます: ' + $Path) }

$content = Read-TextFile $fullPath
$lines = [regex]::Split($content, '\r\n|\n|\r')
$problems = New-Object System.Collections.ArrayList
$inKsBlockComment = $false
$inIscript = $false
$script:JsBlockComment = $false

for ($lineIndex = 0; $lineIndex -lt $lines.Length; $lineIndex++) {
    $lineNumber = $lineIndex + 1
    $line = $lines[$lineIndex]

    if ($inIscript) {
        $maskedForTag = Mask-KsComments -Line $line -InBlockComment ([ref]$inKsBlockComment)
        $tagsInJs = Get-TagsFromLine $maskedForTag
        $closed = $false

        foreach ($tag in $tagsInJs) {
            $parsed = Parse-Tag $tag.Text
            if ($null -ne $parsed -and $parsed.Name -eq 'endscript') {
                $inIscript = $false
                $script:JsBlockComment = $false
                $closed = $true
                break
            }
        }

        if (-not $closed) {
            Add-IscriptProblems -List $problems -File $fullPath -LineNumber $lineNumber -Line $line
        }

        continue
    }

    $masked = Mask-KsComments -Line $line -InBlockComment ([ref]$inKsBlockComment)
    foreach ($tag in (Get-TagsFromLine $masked)) {
        $parsed = Parse-Tag $tag.Text
        if ($null -eq $parsed) { continue }

        if ($parsed.Name -eq 'iscript') {
            $inIscript = $true
            $script:JsBlockComment = $false
            continue
        }

        foreach ($attr in $parsed.Attributes) {
            $columnBase = $tag.StartIndex + $attr.ValueIndex

            if ($attr.Name -eq 'cond') {
                Add-ConditionProblems -List $problems -File $fullPath -Line $lineNumber -ExpressionColumn $columnBase -Expression $attr.Value -ContextLabel 'cond 属性'
                continue
            }

            if ($attr.Name -ne 'exp') { continue }

            switch ($parsed.Name) {
                'if' { Add-ConditionProblems -List $problems -File $fullPath -Line $lineNumber -ExpressionColumn $columnBase -Expression $attr.Value -ContextLabel '[if exp]' }
                'elsif' { Add-ConditionProblems -List $problems -File $fullPath -Line $lineNumber -ExpressionColumn $columnBase -Expression $attr.Value -ContextLabel '[elsif exp]' }
                'ignore' { Add-ConditionProblems -List $problems -File $fullPath -Line $lineNumber -ExpressionColumn $columnBase -Expression $attr.Value -ContextLabel '[ignore exp]' }
                'eval' { Add-AssignmentContextProblems -List $problems -File $fullPath -Line $lineNumber -ExpressionColumn $columnBase -Expression $attr.Value -ContextLabel '[eval exp]' }
                'button' { Add-AssignmentContextProblems -List $problems -File $fullPath -Line $lineNumber -ExpressionColumn $columnBase -Expression $attr.Value -ContextLabel '[button exp]' }
                'glink' { Add-AssignmentContextProblems -List $problems -File $fullPath -Line $lineNumber -ExpressionColumn $columnBase -Expression $attr.Value -ContextLabel '[glink exp]' }
                'emb' { Add-ExpressionContextProblems -List $problems -File $fullPath -Line $lineNumber -ExpressionColumn $columnBase -Expression $attr.Value -ContextLabel '[emb exp]' }
                'trace' { Add-ExpressionContextProblems -List $problems -File $fullPath -Line $lineNumber -ExpressionColumn $columnBase -Expression $attr.Value -ContextLabel '[trace exp]' }
            }
        }
    }
}

if ($problems.Count -eq 0) {
    Write-Host '問題は見つかりませんでした。' -ForegroundColor Green
    exit 0
}

Write-Host ($problems.Count.ToString() + ' 件の問題候補が見つかりました。') -ForegroundColor Yellow
foreach ($problem in $problems) {
    Write-Problem $problem
}

exit 1

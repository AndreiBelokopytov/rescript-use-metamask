type request = {method: string}

@val @scope("ethereum")
external on: @string
[
  | #accountsChanged(array<string> => unit)
  | #chainChanged(string => unit)
] => unit = "on"

@val @scope("ethereum")
external off: @string
[#accountsChanged(array<string> => unit) | #chainChanged(string => unit)] => unit = "removeListener"

@val @scope("ethereum")
external request: request => Promise.t<array<string>> = "request"

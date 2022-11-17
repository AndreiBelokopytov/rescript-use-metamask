type onboarding

@module("@metamask/onboarding")
external isMetaMaskInstalled: unit => bool = "isMetaMaskInstalled"

@new @module external new: unit => onboarding = "@metamask/onboarding"
@send external startOnboarding: onboarding => unit = "startOnboarding"
@send external stopOnboarding: onboarding => unit = "stopOnboarding"

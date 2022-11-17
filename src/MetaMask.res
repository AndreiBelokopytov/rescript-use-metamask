open Promise

type state =
  | NotInstalled
  | NotConnected
  | ConnectionError(string)
  | Connecting
  | Connected(array<string>)

let useMetaMask = () => {
  let initialState = switch Onboarding.isMetaMaskInstalled() {
  | true => NotConnected
  | false => NotInstalled
  }

  let (onboardingUtil, _) = React.useState(_ => Onboarding.new())
  let (state, setState) = React.Uncurried.useState(_ => initialState)

  let onAccountsChanged = React.useCallback0(accounts => {
    if Js.Array2.length(accounts) > 0 {
      setState(._ => Connected(accounts))
    } else {
      setState(._ => NotConnected)
    }
    onboardingUtil->Onboarding.stopOnboarding
  })

  let connect = React.useCallback1(() => {
    if !Onboarding.isMetaMaskInstalled() {
      onboardingUtil->Onboarding.startOnboarding
      Promise.resolve()
    } else {
      setState(._ => Connecting)
      Ethereum.request({method: "eth_requestAccounts"})
      ->then(accounts => {
        onAccountsChanged(accounts)
        Promise.resolve()
      })
      ->catch(error => {
        switch error {
        | Js.Exn.Error(error) =>
          switch Js.Exn.message(error) {
          | Some(message) => setState(. _ => ConnectionError(message))
          | _ => setState(. _ => ConnectionError("Unknown error"))
          }
        }
        Promise.resolve()
      })
    }
  }, [onAccountsChanged])

  let disconnect = React.useCallback0(() => setState(._ => NotConnected))

  React.useEffect1(() => {
    if Onboarding.isMetaMaskInstalled() {
      Ethereum.on(#accountsChanged(onAccountsChanged))
    }
    Some(
      () => {
        if Onboarding.isMetaMaskInstalled() {
          Ethereum.off(#accountsChanged(onAccountsChanged))
        }
      },
    )
  }, [onAccountsChanged])

  (state, connect, disconnect)
}

let useChainId = () => {
  let (chainId, setChainId) = React.Uncurried.useState(_ => None)

  let onChainChanged = React.useCallback0(chainId => {
    setChainId(._ => Some(chainId))
  })

  React.useEffect1(() => {
    if Onboarding.isMetaMaskInstalled() {
      Ethereum.on(#chainChanged(onChainChanged))
    }

    Some(
      () => {
        if Onboarding.isMetaMaskInstalled() {
          Ethereum.off(#chainChanged(onChainChanged))
        }
      },
    )
  }, [onChainChanged])

  chainId
}

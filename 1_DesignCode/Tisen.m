%  Function Tisen solves for the temperature isentropically.
    function To = Tisen(Tcns,gamma,M)
        To = Tcns*(1+(gamma-1)/2*M^2)^(-1);
    end
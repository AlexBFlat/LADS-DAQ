%  Function Tisen solves for the temperature isentropically.
    function Po = Tisen(Tcns,gamma,M)
        Po = Tcns*(1+(gamma-1)/2*M^2)^(-1);
    end
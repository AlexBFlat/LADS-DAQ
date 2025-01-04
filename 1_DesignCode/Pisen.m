%  Function Pisen solves for the pressure isentropically.
    function Po = Pisen(Pcns,gamma,M)
        Po = Pcns*(1+(gamma-1)/2*M^2)^(-gamma/(gamma-1));
    end
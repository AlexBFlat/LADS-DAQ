%  Function rhoisen solves for the density isentropically.
    function Po = rhoisen(rhocns,gamma,M)
        Po = rhocns*(1+(gamma-1)/2*M^2)^(-1/(gamma-1));
    end
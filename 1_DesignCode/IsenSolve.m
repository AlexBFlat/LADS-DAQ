function [Px,Tx,rhox,ax,vx,Vx,Dx,Mx] = IsenSolve(A,Ax,gamma,R,Pcns,Tcns,Pt,rhocns,At,mdot)
[z, Asz] = size(A);
it = find(Ax==0);
Pr = 4*gamma/(9*gamma-5);
cstar = Pcns*At/mdot;
syms Mxs;
for i = 1:1:Asz
AxAt(i) = A(i)/At; % Finds area ratio at each point.
funcM = ((gamma+1)/2)^(-(gamma+1)/2/(gamma-1))*(1+(gamma-1)/2*Mxs^2)^((gamma+1)/2/(gamma-1))/Mxs - AxAt(i);

if i <= it
    Minit = .1;
else
    Minit = 1.1;
end
if i == it
Mx(i) = 1;
Px(i) = Pt;
else
Mx(i) = real(vpasolve(funcM,Mxs,Minit));
end
Px(i) = Pisen(Pcns,gamma,Mx(i));
Tx(i) = Tisen(Tcns,gamma,Mx(i));
rhox(i) = rhoisen(rhocns,gamma,Mx(i));
ax(i) = sqrt(gamma*R*Tx(i));
vx(i) = Mx(i)*ax(i);
Vx(i) = 1/rhox(i);
Dx(i) = abs(sqrt(4*A(i)/pi));
% Heat transfer
%mux(i) = (46.6e-10)*M^.5*(Tx(i)*9/5)^.6;
%Re(i) = rhox(i)*vx(i)*Dx(i)/12/(mux(i)*12);
%if Re>4000
%    r(i) = Pr^.35;
%else
%    r(i) = Pr^.5;
%end
%fprintf('Iteration: %f',i);
end
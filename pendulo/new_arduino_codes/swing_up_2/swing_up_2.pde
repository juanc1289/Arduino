mp=;
lb=;
lp=;
g=;
Ib=;
Ip=;
P=78.24;
D=4.48;
alpha_dot=(last_alpa-alpha)/dt;
theta_dot=(last_theta-theta)/dt;
Eref=mp*g*lp;
Etot=0.5*Ib*sq(alpha_dot)+0.5*mp*sq(lb)*sq(alpha_dot)+0.5*(mp*sq(lp)+Ip)*sq(theta_dot)+mp*lb*alpha_dot*lp*theta_dot*cos(theta)+sq(lp*theta_dot*sin(theta))-mp*g*lp*cos(theta);
Vm=P*(theta-alpha)-D*alpha_dot;
U_swing=Vm*|Eref-Etot|*theta_dot*cos(theta);


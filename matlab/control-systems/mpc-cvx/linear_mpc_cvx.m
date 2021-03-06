%%  Linear Model Predictive Control example implementations using CVX
%
%

%%  Model the System
clear all;
Ts = .01; % sampling time;

A = zeros(2,2); A(1,2) = 1; A(2,2) = -1;
B = zeros(2,1); B(2,1) = 1;
C = eye(2,2); D = zeros(2,1);
sys_d = c2d(ss(A,B,C,D),Ts,'zoh');
A_m = sys_d.A; B_m = sys_d.B; C_m = sys_d.C; D_m = sys_d.D;

%%  Initial Conditions

x0 = [0 0];

%%  System Constraints

x_max = [100 100]; 
u_max = 1;


%%  Tuning Parameters

Q = diag([100 1]);
R = .01;
N = 10;

%%  CVX Code :: 2-Norm
clc 
cvx_begin
    variables x_1(N) x_2(N) u(N);
    minimize( norm([x_1 x_2]*Q,2) + quad_form(u,R) )
    subject to 
        x_1(1:end)  ==  A_m(1,1)*[x0(1); x_1(1:(end-1))] + A_m(1,2)*[x0(2); x_2(1:(end-1))] + B_m(1,1)*u(1:end);
        x_2(1:end)  ==  A_m(2,1)*[x0(1); x_1(1:(end-1))] + A_m(2,2)*[x0(2); x_2(1:(end-1))] + B_m(2,1)*u(1:end);
        norm(x_1,1) <=  x_max(1);
        norm(x_2,1) <=  x_max(2);
        norm(u,1)   <=  u_max;
cvx_end

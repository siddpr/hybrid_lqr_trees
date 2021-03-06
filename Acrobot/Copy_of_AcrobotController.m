classdef AcrobotController < DrakeSystem
  properties
    p
  end
  methods
    function obj = AcrobotController(plant)
      obj = obj@DrakeSystem(0,0,4,1,true,true);
      obj.p = plant;
      obj = obj.setInputFrame(plant.getStateFrame);
      obj = obj.setOutputFrame(plant.getInputFrame);
    end
    
    function u = output(obj,t,~,x)
        
        function r = inregion(in)
            error1 = pi/6;
             error2 = pi/12;
            r = abs(  in(1))< (pi +error1) && in(1) > (pi -error1) && abs(in(2)) < (error2);
        end
      q = x(1:2);
      qd = x(3:4);
      
      % unwrap angles q(1) to [0,2pi] and q(2) to [-pi,pi]
      q(1) = q(1) - 2*pi*floor(q(1)/(2*pi));
      q(2) = q(2) - 2*pi*floor((q(2) + pi)/(2*pi));

      %%%% put your controler here %%%%
      % You might find some of the following functions useful
      % [H,C,B] = obj.p.manipulatorDynamics(q,qd);
      % com_position = obj.p.getCOM(q);
      % mass = obj.p.getMass();
      % gravity = obj.p.gravity;
      % Recall that the kinetic energy for a manpulator given by .5*qd'*H*qd
      u = 0;
      
       
      [H,C,B] = obj.p.manipulatorDynamics(q,qd);
      [f,df] = obj.p.dynamics(t,x,u);
    %x
      global time X U T
      persistent count 
      persistent avA avB com_position K S x_init pinr pq px
      
      
      
      
      
      
      com = obj.p.getCOM(q);
      
     
       E = .5*qd'*H*qd + com(2) * obj.p.getMass() * 9.8;

       com = obj.p.getCOM([pi,0]);
       Ed = com(2) * obj.p.getMass() * 9.8;
       
       Hinv = H^-1;
       a1=Hinv(1,1);
       a2=Hinv(1,2);
       a3=Hinv(2,2);
       c1=C(1);
       c2=C(2);
       
       count;
        k1 = 1;
        k2 = 10;
        k3 = 10;
      
      
      
      qd(2);
       ue = - k1*(E-Ed)*qd(2);
       
       up= (-k2*q(2) -k3*qd(2) +c1*a2+c2*a3)/a3;
      u=ue+up;
        x_init = [pi 0 0 0]';
        if isempty(avA)
        avA = 0;
        avB = 0;
        count = 1;
        pinr=1;
        time = 0;
        X=[];
        U=[];
        end
    
    
        count = count +1;
        time = time+1;
     
     
      
      [f,df] = obj.p.dynamics(0,[pi;0;0;0],0);
      avA = df(:,2:5);
      avB = df(:,end);
  
      Q = eye(4);
      R = 1;
      [K,S] = lqr(avA,avB,Q,R);
     
    q;   
    inr=inregion([q(1),q(2)]);
    if(pinr && ~inr)
    end
    pq=q;
    px=x;
    pinr = inr;
    if(count>4)
       
    %u=-K*([q;x(3);x(4)] - x_init);
    global rec
    if(q(1)<5)
    rec(count,:)=[q(1),q(2),(E-Ed)];
    end
    end
      xe = [q;qd] - [pi;0;0;0];
      
    
     if( xe'*S*xe < 1000)
      [q' E-Ed];
      u=-K*(xe);
     end
     
      %%%% end of your controller %%%%
   
  finalu = u;
      % leave this line below, it limits the control input to [-20,20]
      
      u = max(min(u,20),-20);
      U(time) = u;
      X(:,time) = x;
      T(time) = t;
     
      
      % This is the end of the function
    end
  end
  
  methods (Static)
    function [t,x,x_grade]=run()
      plant = PlanarRigidBodyManipulator('Acrobot.urdf');
      controller = AcrobotController(plant);
      v = plant.constructVisualizer;
      sys_closedloop = feedback(plant,controller);
      
%      %x0 = [.1*(rand(4,1) - 1)]; % start near the downward position
%      x0 = [pi/2;0;0;0];  % start near the upright position
%       xtraj=simulate(sys_closedloop,[0 10],x0);
      
      x0 = [.1*(rand(4,1) - 1)]; % start near the downward position
%     x0 = [pi - .1*randn;0;0;0];  % start near the upright position
      xtraj=simulate(sys_closedloop,[0 10],x0);
      
      
      v.axis = [-4 4 -4 4];
      playback(v,xtraj);
      t = xtraj.pp.breaks;
      x = xtraj.eval(t);
      t_grade = linspace(3,4,98);
      x_grade = [xtraj.eval(0) xtraj.eval(t_grade) xtraj.eval(10)];
      x_grade = x_grade';
    end
  end
end

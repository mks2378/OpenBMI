function [ output_args ] = racing_on( CSP, LDA, band )
%RACING_ON Summary of this function goes here
%   Detailed explanation goes here


bbci_acquire_bv('close');
params = struct;
state = bbci_acquire_bv('init', params);
orig_Dat=[];

buffer_size=5000;
data_size=1500;
orig_Dat=zeros(buffer_size, size(state.chan_sel,2));

escapeKey = KbName('esc');
waitKey=KbName('s');
%% UDP
% UDP sender
ipA = 'RemoteIPAddress';
portA = 'RemoteIPPort';
% ipB = '192.168.0.10';
ipB = '163.152.74.130';
portB = 5555;
udpbuff = 0;

udpB = udp(ipB, portB);
fopen(udpB);
udpB.Status

% �Ķ�: 11, ����: 12. ���:13,

play=true;
buffer=[];
buffer2=[];
bu_i=1;
tic
stop=true;
temp=1;
while play
    [data, markertime, markerdescr, state] = bbci_acquire_bv(state);
    orig_Dat=[orig_Dat; data];
    if length(orig_Dat)>buffer_size % prevent overflow
        Dat=orig_Dat(end-buffer_size+1:end,:);
        orig_Dat=Dat;  %%
        Dat2.x=Dat;
        Dat2.fs=state.fs;
        %         Dat=prep_resample(Dat2,500);
        Dat=Dat2.x;
        fDat=prep_filter(Dat, {'frequency', band;'fs',1000});%state.fs });
        fDat=fDat(end-data_size:end,:); % data
        
        
        for i=1:length(CSP)
            tm=func_projection(fDat, CSP{i});
            ft=func_featureExtraction(tm, {'feature','logvar'});
            [cf_out(i)]=func_predict(ft, LDA{i});
        end
        
        %% hblee 2016_7_14
%         ovrOut(1) = cf_out(7);
%         ovrOut(2) = cf_out(8);
%         ovrOut(3) = cf_out(9);
%         if stop
%             if  cf_out(10) < 0
%                 b=4;
%             else
%                 [tm1 tm2] = min(ovrOut);
%                 if tm2==3
%                 b=tm2
%                 else
%                   if cf_out(1)<0
%                       b=1;
%                   else
%                       b=2;
%                   end
%                 end
%                
%             end
%         end
%% basic ovr
%         if cf_out(10)<0
%             output=4;
%         else
%             [a b]=min(cf_out(7:9));
%             output=b;
%         end
        if cf_out(10)<3
            b=4;
        elseif cf_out(9)<1
            b=3
        else
            if cf_out(1)-3<0
                b=1;
            else
                b=2;
            end            
%             [a b]=min(cf_out(7:8));
%             output=b;
        end
        %%
        tempFlag = false;
        temp_2 = 0;
        buffer(bu_i)=b;
        bu_i=bu_i+1;
        if length(buffer)>10
            tm_bf=buffer(end-8:end);
            if length(find(tm_bf==4))>5
                b=4;
            end
            if length(find(tm_bf==4))<2
                if temp==6
                    tempFlag = true;
                    temp=0;
                else
                    temp=temp+1;
                end
                
            end
            if tempFlag
                b = 2;
                temp_2 = temp_2+1;
                if temp_2 == 5
                    tempFlag = false;
                end
            end
                
        end
        str=sprintf('%.3f   %.3f   %.3f   %.3f   %.3f   %.3f   %.3f   %.3f   %.3f   %.3f,  ans: %d', ...
            cf_out(1),cf_out(2),cf_out(3),cf_out(4),cf_out(5),cf_out(6),cf_out(7),cf_out(8),cf_out(9),cf_out(10), b);
        str
        
        switch b
            case 1,
                fwrite(udpB, uint8(12));     % SPEED Player1
            case 2,
                fwrite(udpB, uint8(11));     % JUMP Player1
            case 3,
                fwrite(udpB, uint8(13));     % ROLL Player1
                
            case 4,
            otherwise,
                
        end
        pause(0.2);
        udpB.ValuesSent;
    end
end

fclose(udpB);
delete(udpB);
end


%             %% mhlee 2016_7_14
%             if stop
%                 if  cf_out(4) > 5 && cf_out(5) >5 % cf_out(10) < 10 &&
%                     %                 disp('rest');
%                     b=4;
%                 elseif cf_out(2)>5% >10 && cf_out(3) >5
%                     disp('foot');
%                     b=3;
%                 elseif cf_out(1)>3
%                     %                 disp('left');
%                     b=2;
%                 elseif cf_out(1)<4
%                     %                 disp('right');
%                     b=1;
%                 else
%                     %                 disp('foot');
%                     %                 b=3;
%                     %                 disp('non'); �߳����� ������ �Ÿ��� �� �ȳ����� Ŭ������ ��������
%                     %                 b=5
%                 end
%             else
%                 b=4;
%             end

% 
% [ keyIsDown, seconds, keyCode ] = KbCheck;
% if keyIsDown
%     if keyCode(escapeKey)
%         ShowCursor;
%         
%         fclose(udpB);
%         delete(udpB);
%         play=false;
%     elseif keyCode(waitKey)
%         warning('stop')
%         GetClicks(w);
%         Screen('Close',tex1);
%     else
%     end
% end

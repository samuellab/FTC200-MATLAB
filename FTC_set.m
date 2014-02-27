function FTC_set(str, val)
% str:
%   'SV' : setpoint (val = temperature in C)
%   'power' : power output duty cycle in [-1 ,1]
%   'enable' : boolean enable signal for PID control

    global FTC;

    switch str
        case 'SV'
            req = uint8(hex2dec(['01';'05';'00';'00']));
            val = val*100;
            req(5:6) = fliplr(typecast(uint16(val),'uint8'));
        case 'power'
            req = uint8(hex2dec(['01';'05';'00';'03']));
            val = val*100;
            req(5:6) = fliplr(typecase(int16(val),'uint8'));
        case 'enable'
            switch val
                case 'off' %0
                    req = uint8(hex2dec(['01';'05';'00';'04';'00';'00']));
                case 'PID' %3
                    req = uint8(hex2dec(['01';'05';'00';'04';'00';'03']));
                case 'power' %2
                    req = uint8(hex2dec(['01';'05';'00';'04';'00';'02']));
                otherwise
                    error('illegal value for enable');
            end
        otherwise
            error(['Set ' str ' not implemented']);
    end


    fwrite(FTC.serial_object, req);
    res = fread(FTC.serial_object, 6);

    % first two bytes of response should match request
    if ~all(req(1:2)==res(1:2))
      error('Unexpected response from FTC module');
    end
    
end
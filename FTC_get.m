function val = FTC_get(str)
% val = FTC_get(str)
% str:
%   'power' : [double] power output duty cycle in [-1, 1]
%   'PV' : [double] thermocouple value (Celsius)
%   'SV' : [double] setpoint (Celsius)
%   'DIR': [boolean] hot/cold direction (boolean)
%   'enable' : [string] 'off', 'power', or 'PID'
  
  global FTC;

  switch str
      case 'power'
          req = uint8(hex2dec(['01';'03';'00';'03';'00';'00']));
          parse = @(x) double(x(5)*256+x(6))/10000;
      case 'PV'
          req = uint8(hex2dec(['01';'03';'10';'00';'00';'00']));
          parse = @(x) double(x(5)*256+x(6))/100;
      case 'SV'
          req = uint8(hex2dec(['01';'03';'00';'00';'00';'00']));
          parse = @(x) double(x(5)*256+x(6))/100;
      case 'DIR'
          req = uint8(hex2dec(['01';'03';'00';'0C';'00';'00']));
          parse = @parse_dir;
      case 'enable'
          req = uint8(hex2dec(['01';'03';'00';'04';'00';'00']));
          parse = @parse_enable;
      otherwise
          error(['Get ' str ' not implemented']);
  end
  
  fwrite(FTC.serial_object, req);
  res = fread(FTC.serial_object, 6);
  
  % response format should be XX XX 00 02 XX XX
  assert(all(res(3:4) == [0; 2]), 'Unexpected response from FTC module');
  
  % first two bytes of response should match request
  if ~all(req(1:2)==res(1:2))
      error('Unexpected response from FTC module');
  end
  
  val = parse(res);

end

function y = parse_dir(x)
    switch x(6)
        case 9
            y = true;
        case 10
            y = false;
    end
end

function  y = parse_enable(x)
    switch x(6)
        case 0
            y = 'off';
        case 3
            y = 'PID';
        case 2
            y = 'power';
    end            
end
function val = FTC_get(str)
% str:
%   'PV' : thermocouple value
%   'SV' : setpoint
  
  global FTC;

  switch str
      case 'PV'
          req = uint8(hex2dec(['01';'03';'10';'00';'00';'00']));
          parse = @(x) (x(5)*256+x(6))/100;
      case 'SV'
          req = uint8(hex2dec(['01';'03';'00';'00';'00';'00']));
          parse = @(x) (x(5)*256+x(6))/100;
      case 'ACT'
          req = uint8(hex2dec(['01';'03';'00';'0C';'00';'00']));
          parse = @(x) x;
      case 'enable'
          req = uint8(hex2dec(['01';'03';'00';'04';'00';'00']));
          parse = @(x) x;
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
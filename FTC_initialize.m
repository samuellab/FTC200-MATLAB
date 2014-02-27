function FTC_initialize
% opens the serial connection to an FTC controller and ensures the
% communication protocol is properly configured

  serial_port = 'COM7';
  baud_rate = 38400;
  data_length = 8; % bits

  global FTC;
  
  if ~isstruct(FTC)
      FTC = struct('serial_object',serial(serial_port));
      
  end
  
  set(FTC.serial_object, 'BaudRate', baud_rate);
  fopen(FTC.serial_object);

end
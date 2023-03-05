%% Countdown Clock
% Using a 4 digit 7 segment display, NeoPixel strip, and passive buzzer
% Made in 12 hours as part of the MakeOHI/O 24 hour makeathon

% Setup
clear;
clc;

% Variables
a = arduino('COM5','ESP32-WROOM-DevKitV1','Libraries',["ShiftRegister", "Adafruit/NeoPixel"]);

dataPin = 'D5';
clockPin = 'D18';
latchPin = 'D19';

register = shiftRegister(a,'74HC595',dataPin,clockPin,latchPin);

dinPin = 'D12';
numPixels = 8;
neostrip = addon(a,'Adafruit/Neopixel', dinPin, numPixels);

digitPins = ["D32", "D33", "D25", "D26"];

digitTable = {...
    '00111111', ...  % 0
    '00000110', ...  % 1
    '01011011', ...  % 2
    '01001111', ...  % 3
    '01100110', ...  % 4
    '01101101', ...  % 5
    '01111101', ...  % 6
    '00000111', ...  % 7
    '01111111', ...  % 8
    '01101111'  ...  % 9
};

% Main loop
while true
    prompt = "Set a timer for how many minutes? Enter a number 1-99: ";
    startTime = input(prompt);
    lightPct = 1;

    numbers = [floor(startTime/10), mod(startTime, 10), 0, 0];

    while numbers(1) >= 0
        while numbers(2) >= 0
            while numbers(3) >= 0
                while numbers(4) >= 0
                    for n = 1:4
                        digit = digitTable{numbers(n)+1};
                        write(register,digit);
                
                        number = digitPins(n);
                        writeDigitalPin(a,number,0);
                        pause(.01);
                        writeDigitalPin(a,number,1);
                    end
                    currentSec = (numbers(4) + 10*numbers(3) + ...
                        (numbers(2) + 10*numbers(1))*60);
                    lightPct = (currentSec / (startTime * 60)) * 8;
                    if lightPct == 0
                        writeColor(neostrip, [0,0,0]);
                    elseif ceil(lightPct) == 8
                        writeColor(neostrip, 1:8, [0,0,100]);
                    else
                        writeColor(neostrip, ceil(lightPct)+1:8, [0,0,0]);
                    end
                    numbers(4) = numbers(4) - 1;
                end
                numbers(3) = numbers(3) - 1;
                numbers(4) = 9;
            end
            numbers(2) = numbers(2) - 1;
            numbers(3) = 5;
        end
        numbers(1) = numbers(1) - 1;
        numbers(2) = 9;
    end

    % Ending buzzer
    notelen = 1/(114*4/60);
    for music = 1:2
        writePWMDutyCycle(a,"D2",.1);
        pause(notelen);
        writePWMDutyCycle(a,"D2",.2);
        pause(notelen);
        writePWMDutyCycle(a,"D2",.4);
        pause(notelen);
        writePWMDutyCycle(a,"D2",.2);
        pause(notelen);
        writePWMDutyCycle(a,"D2",.6);
        pause(3*notelen);
        writePWMDutyCycle(a,"D2",.6);
        pause(3*notelen);
        if music == 1
            writePWMDutyCycle(a,"D2",.5);
            pause(3*notelen);
        else
            writePWMDutyCycle(a,"D2",.4);
            pause(3*notelen);
        end
        writePWMDutyCycle(a,"D2",0);
        pause(.1);
    end
    writePWMDutyCycle(a,"D2",0);
    fprintf("I will never give you up\n")

    % Beeping
    %     for music = 1:3
    %         writePWMDutyCycle(a,"D2",.1);
    %         pause(.25);
    %         writePWMDutyCycle(a,"D2",0);
    %     end

end

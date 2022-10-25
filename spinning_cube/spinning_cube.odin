/*
This is a direct port of 'servetgulnaroglu's spinning cube app made in C to Odin. You can find the original repo here: https://github.com/servetgulnaroglu
*/

package main 

import "core:fmt"
import "core:math"
import "core:mem"
import "core:c/libc"
import "core:time"

A, B, C : f32;

cube_width: f32: 20;
width, height: f32: 160, 44;
zBuffer: [160 * 44]f32;
buffer: [160 * 44]u8; 
background_ascii_code: int : ' ';
distance_from_cam: int : 100;
horizontal_offset: f32: -2 * cube_width;
K1: f32: 40;

increment_speed: f32: 0.6;

x, y, z: f32;
ooz: f32;
xp, yp: int;
idx: int;


calc_x :: proc(i: f32, j: f32, k: f32) -> f32 {
    return j * math.sin(A) * math.sin(B) * math.cos(C) - k * math.cos(A) * math.sin(B) * math.cos(C) +
    j * math.cos(A) * math.sin(C) + k * math.sin(A) * math.sin(C) + i * math.cos(B) * math.cos(C);
}

calc_y :: proc(i: f32, j: f32, k: f32) -> f32 {
    return j * math.cos(A) * math.cos(C) + k * math.sin(A) * math.cos(C) -
    j * math.sin(A) * math.sin(B) * math.sin(C) + k * math.cos(A) * math.sin(B) * math.sin(C) -
    i * math.cos(B) * math.sin(C);
}

calc_z :: proc(i: f32, j: f32, k: f32) -> f32 {
    return k * math.cos(A) * math.cos(B) - j * math.sin(A) * math.cos(B) + i * math.sin(B);
}

calc_for_surface :: proc(cubeX: f32, cubeY: f32, cubeZ: f32, ch: int) {
    x = calc_x(cubeX, cubeY, cubeZ);
    y = calc_y(cubeX, cubeY, cubeZ);
    z = calc_z(cubeX, cubeY, cubeZ) + f32(distance_from_cam);

    ooz = 1 / z;

    xp = int(width / 2 + horizontal_offset + K1 * ooz * x * 2);
    yp = int(height / 2 + K1 * ooz * y);

    idx = xp + yp * int(width);
    if (idx >= 0 && idx < int(width * height)) {
        if (ooz > zBuffer[idx]) {
          zBuffer[idx] = ooz;
          buffer[idx] = u8(ch);
        }
      }
}

main :: proc() {
    libc.system("cls"); // clears console
    for {
        mem.set(&buffer, u8(background_ascii_code), int(width * height));
        mem.set(&zBuffer, 0, int(width * height * 4));

        for cubeX: f32 = -cube_width; cubeX < cube_width; cubeX += increment_speed {
            for cubeY: f32 = -cube_width; cubeY < cube_width; cubeY += increment_speed {
                calc_for_surface(cubeX, cubeY, -cube_width, '@');
                calc_for_surface(cube_width, cubeY, cubeX, '$');
                calc_for_surface(-cube_width, cubeY, -cubeX, '~');
                calc_for_surface(-cubeX, cubeY, cube_width, '#');
                calc_for_surface(cubeX, -cube_width, -cubeY, ';');
                calc_for_surface(cubeX, cube_width, cubeY, '+');
            }

        }

        fmt.printf("\x1b[H"); // sets cursor to 'home'
        for k := 0; k < int(width * height); k += 1 {
          libc.putchar(i32(k % int(width) != 0 ? buffer[k] : 10));
        }

        A += 0.05;
        B += 0.05;
        C += 0.01;

        time.accurate_sleep(1000);
    }
}
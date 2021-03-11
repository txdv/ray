// build with `zig build-exe cimport.zig -lc -lraylib`
const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const InputBuffer = struct {
    buffer: [2048]u8 = undefined,
    current: usize = 0,

    pub fn new() InputBuffer {
        var buf = InputBuffer { };
        buf.buffer[0] = 0;
        return buf;
    }

    pub fn add(buf: *InputBuffer, ch: u8) void {
        buf.*.buffer[buf.*.current] = ch;
        buf.*.current += 1;
        buf.*.buffer[buf.*.current] = 0;
    }

    pub fn delete(buf: *InputBuffer) void {
        if (buf.*.current > 0) {
            buf.*.current -= 1;
        }
        buf.*.buffer[buf.*.current] = 0;
    }

    pub fn draw(buf: *InputBuffer, x: u32, y: u32, size: u32) void {
        const slice = buf.*.buffer[0..];
        ray.DrawText(slice, @intCast(c_int, x), @intCast(c_int, y), @intCast(c_int, size), ray.MAROON);
    }

    pub fn handle(buf: *InputBuffer) void {
        var pressed = ray.GetCharPressed();
        var ch: u8 = @truncate(u8, @intCast(u32, pressed));

        if (ray.IsKeyPressed(ray.KEY_BACKSPACE)) {
            buf.delete();
        } else if (ch != 0) {
            buf.add(ch);
        }
    }
};

var c: u32 = 1234;

pub fn main() !void {
    var in = InputBuffer.new();

    const screenWidth = 800;
    const screenHeight = 450;

    ray.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    var position: ray.Vector2 = ray.Vector2 {
        .x = 100,
        .y = 100
    };

    var font = ray.GetFontDefault();
    var y: c_int = 0;

    var r: f32 = 0;

    var input_buffer: [1024]u8 = undefined;
    input_buffer[0] = 0;
    const input_slice = input_buffer[0..];
    var input_i: usize = 0;

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();

        if (ray.IsKeyDown(ray.KEY_RIGHT)) {
            position.x += 2.0;
        }
        if (ray.IsKeyDown(ray.KEY_LEFT)) {
            position.x -= 2.0;
        }
        if (ray.IsKeyDown(ray.KEY_UP)) {
            position.y -= 2.0;
            y -= 2;
        }
        if (ray.IsKeyDown(ray.KEY_DOWN)) {
            position.y += 2.0;
            y += 2;
        }

        if (ray.IsKeyDown(ray.KEY_ENTER)) {
            r = 240;
        }

        var buffer: [100]u8 = undefined;
        const buffer_slice = buffer[0..];

        in.handle();

        in.draw(0, 0, 20);
        in.draw(0, 20, 20);
        in.draw(0, 40, 20);

        if (ray.IsMouseButtonDown(0)) {
            var mx = ray.GetMouseX();
            var my = ray.GetMouseY();
            const a = try std.fmt.bufPrintZ(buffer_slice, "x: {} y: {}", .{ mx, my });
            ray.DrawText(@ptrCast([*c]const u8, a), 0, 0, 20, ray.MAROON);

        }

        if (r > 0) {
            r = r / 1.05;
        }

        ray.ClearBackground(ray.RAYWHITE);

        var i: c_int = 0;
        while (i < 10) {
            ray.DrawText("Hello, World!", 190, @floatToInt(i32, r) + y + i * 22 + 10, 20, ray.MAROON);
            i += 1;
        }
        //ray.DrawTextEx(font, "Hello, World!", position, 20, 1.0, ray.MAROON);
        //ray.DrawTextEx(font, "Hello, World!", position, 20, 1.0, ray.MAROON);
    }
}

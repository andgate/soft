const std = @import("std");

const Token = enum {
    Variable,
    Lambda,   // λ or \
    Dot,      // .
    OpenParen,
    CloseParen,
};

const TokenType = struct {
    kind: Token,
    value: []const u8,
};

const Lexer = struct {
    input: []const u8,
    index: usize,
    pub fn nextToken(self: *Lexer) ?TokenType {
        while (self.index < self.input.len) {
            const c = self.input[self.index];
            self.index += 1;

            switch (c) {
                ' ': |'\n'|'\t' => {}, // skip whitespace
                '\\' => return TokenType{ .kind = .Lambda, .value = "\\", },
                '.' => return TokenType{ .kind = .Dot, .value = ".", },
                '(' => return TokenType{ .kind = .OpenParen, .value = "(", },
                ')' => return TokenType{ .kind = .CloseParen, .value = ")", },
                else => {
                    if (c >= 'a' and c <= 'z') {
                        return TokenType{ .kind = .Variable, .value = self.input[self.index - 1..self.index], };
                    } else {
                        return null;
                    }
                }
            }
        }
        return null;
    }
};

const Expr = union(enum) {
    Variable: []const u8,
    Lambda: struct {
        param: []const u8,
        body: *Expr,
    },
    Application: struct {
        left: *Expr,
        right: *Expr,
    },
};

const Parser = struct {
    tokens: []TokenType,
    index: usize,

    pub fn parse(self: *Parser) ?Expr {
        if (self.index >= self.tokens.len) return null;

        const token = self.tokens[self.index];
        self.index += 1;

        switch (token.kind) {
            .Variable => return Expr{ .Variable = token.value },
            .Lambda => |token_lambda| {
                const param = self.tokens[self.index];
                if (param.kind != .Variable) return null;
                self.index += 1;

                const dot = self.tokens[self.index];
                if (dot.kind != .Dot) return null;
                self.index += 1;

                const body = self.parse();
                if (body == null) return null;

                return Expr{ .Lambda = .{ .param = param.value, .body = body } };
            },
            .OpenParen => |token_open| {
                const left = self.parse();
                if (left == null) return null;

                const right = self.parse();
                if (right == null) return null;

                const close = self.tokens[self.index];
                if (close.kind != .CloseParen) return null;
                self.index += 1;

                return Expr{ .Application = .{ .left = left, .right = right } };
            },
            else => return null,
        }
    }
};

pub fn main() anyerror!void {
    const source_code = "\\x. (x x)";
    var lexer = Lexer{ .input = source_code, .index = 0 };

    var tokens: [10]TokenType = undefined;
    var token_index: usize = 0;
    while (true) {
        const token = lexer.nextToken();
        if (token == null) break;
        tokens[token_index] = token.?;
        token_index += 1;
    }

    var parser = Parser{ .tokens = tokens[0..token_index], .index = 0 };
    const expr = parser.parse();
    if (expr != null) {
        std.debug.print("Parsed successfully!\n", .{});
    } else {
        std.debug.print("Parse error!\n", .{});
    }
}
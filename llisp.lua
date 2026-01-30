--[[
-- LLisp, lisp interpreter written by Lua.
-- Joe Xue(lgxue@Hotmail.com) 2026
--]]

TRACE = false

function trace(t, newline)
    if TRACE and newline then
        io.write(t .. "\n")
    elseif TRACE then
        io.write("TRACE: " .. t)
    end
end

STACK = {}
ATOM = {"ERR", "#t"}

NIL = {"NIL", 0}
ERR = {"ATOM", 1}
TRUE = {"ATOM", 2}
ENV = {}

function cons(ll, lr)
    table.insert(STACK, ll)
    table.insert(STACK, lr)

    return {"CONS", #STACK}
end

function lnot(l)
    return l[1] == 'NIL'
end

function car(l)
    if l[1] == "CONS" or l[1] == "CLOS" then
        return STACK[l[2] - 1]
    end

    return ERR;
end

function cdr(l)
    if l[1] == "CONS" or l[1] == "CLOS" then
        return STACK[l[2]]
    end

    return ERR;
end

PRIM = {
    {
        "eval",
        function(t, e)
        end
    },
    {
        "car",
        function(t, e)
        end
    },
    {
        "-",
        function(t, e)
        end
    },
    {
        "<",
        function(t, e)
        end
    },
    {
        "or",
        function(t, e)
        end
    },
    {
        "cond",
        function(t, e)
        end
    },
    {
        "lambda",
        function(t, e)
        end
    },
    {
        "quote",
        function(t, e)
        end
    },
    {
        "cdr",
        function(t, e)
        end
    },
    {
        "*",
        function(t, e)
        end
    },
    {
        "int",
        function(t, e)
        end
    },
    {
        "and",
        function(t, e)
        end
    },
    {
        "if",
        function(t, e)
        end
    },
    {
        "define",
        function(t, e)
        end
    },
    {
        "cons",
        function(t, e)
        end
    },
    {
        "+",
        function(t, e)
        end
    },
    {
        "/",
        function(t, e)
        end
    },
    {
        "eq?",
        function(t, e)
        end
    },
    {
        "not",
        function(t, e)
        end
    },
    {
        "let*",
        function(t, e)
        end
    },
    {
        "pair?",
        function(t, e)
        end
    }
}


function print_lisp(l)
    local print_list = function(l)
        io.write("(")
        while true do
            print_lisp(car(l))
            l = cdr(l)
            if lnot(l) then
                break
            end
            io.write(" ")
        end
        io.write(")")
    end

    if l[1] == "NIL" then
        io.write("()")
    end

    if l[1] == "ATOM" then
        io.write(ATOM[l[2]])
    end

    if l[1] == "PRIM" then
        io.write("<" .. PRIM[l[2]][1] .. ">")
    end

    if l[1] == "CONS" then
        print_list(l)
    end

    if l[1] == "CLOS" then
        io.write("{" .. l[2] .. "}")
    end

    if l[1] == "NUMBER" then
        io.write(l[2])
    end
end

function get_scan(lisp)
    pos = 1
    return function()
        local token = {}
        trace("POS: " .. pos, false)
        --io.read()

        local c
        while true do
            -- First letter
            c = string.sub(lisp, pos, pos)
            if c ~= ' ' then
                break
            end
            trace("TOKEN: " .. '_', true)
            pos = pos + 1
        end

        if c == '(' or c == ')' or c == '\'' or c == '' then
            -- Consume it
            trace("TOKEN: " .. c, true)
            pos = pos + 1
            return c
        end

        while true do
            --io.write(" 3-> " .. c .. " ")
            c = string.sub(lisp, pos, pos)
            if c == '(' or c == ')' or c == '\'' or c == ' ' or c == '' then
                -- Consume it next round
                break
            end
            table.insert(token, c)
            pos = pos + 1
        end
        trace("TOKEN: " .. table.concat(token), true)
        return table.concat(token)
    end
end

local parse
function atomic(token)
    local n = tonumber(token)

    if not n then
        --default error
        local index = #ATOM + 1
        for i = 1, #ATOM do
            if ATOM[i] == token then
                index = i
                break
            end
        end

        if index == #ATOM + 1 then
            table.insert(ATOM, token)
        end

        trace(ATOM[index], true)
        return {"ATOM", index}
    end

    return {"NUMBER", n}
end

function quote(scan)
    return cons(atomic("quote"), cons(parse(scan(), scan), NIL))
end

function list(scan)
    c = scan()
    trace("IN LIST " .. c, true)
    --print(c)
    if c == ')' then
        trace("()", true)
        return NIL
    end

    --return parse(scan)
    x = parse(c, scan)
    return cons(x, list(scan))
end

function parse(c, scan)
    --local c = scan()
    if c == '(' then
        return list(scan)
    elseif c == '\'' then
        return quote(scan)
    else
        return atomic(c)
    end
end

function equ(ll, lr)
    return ll[1] == lr[1] and ll[2] == lr[2]
end

function pair(l, v, e)
    return cons(cons(l, v), e)
end

-- EVAL
function assoc(l, e)
    while e[1] == "CONS" and not equ(l, car(car(e))) do
        e = cdr(e)
    end

    if e[1] == "CONS" then
        return cdr(car(e))
    end

    return ERR
end

function apply(f, l, e)
    return ERR
end

function eval(l, e)
    if l[1] == "ATOM" then
        return assoc(l, e)
    elseif l[1] == "CONS" then
        return apply(eval(car(l), e), cdr(l), e)
    else
        return l
    end
end

function read()
    local scan = get_scan(io.read())
    return parse(scan(), scan)
end

-- ENV initilization
ENV = pair(TRUE, TRUE, NIL)
for i = 1, #PRIM do
    ENV = pair(atomic(PRIM[i][1]), {"PRIM", i}, ENV)
end

io.write("LLisp -- Lisp interpreter written by Lua")
while true do
    io.write("\n> ")
    --print_lisp(read())
    print_lisp(eval(read(), ENV))
end

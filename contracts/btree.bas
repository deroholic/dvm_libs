
//   ______      _______  ______ _______ _______
//   |_____] ___    |    |_____/ |______ |______
//   |_____]        |    |    \_ |______ |______
//    
//   by Pieswap

Function Initialize() Uint64
	10 IF EXISTS("owner") THEN GOTO 40
	20 STORE("owner", SIGNER())
	30 btInit()
	40 RETURN 0
End Function

Function UpdateCode(c String) Uint64
	10 IF LOAD("owner") != SIGNER() THEN GOTO 30
	20 UPDATE_SC_CODE(c)
	30 RETURN 0
End Function

Function btInit()
	10 STORE("memloc", 0)
	20 STORE("root", createNode(0, 0, ""))
	30 RETURN
End Function

Function getNextLoc() Uint64
	10 DIM m AS Uint64
	20 LET m = LOAD("memloc") + 1
	30 STORE("memloc", m)
	40 RETURN m
End Function

Function createNode(p Uint64, k Uint64, d String) Uint64
	10 DIM n AS Uint64
	20 LET n = getNextLoc()
	30 STORE("np:"+n, p)
	40 STORE("nk:"+n, k)
	50 STORE("nd:"+n, d)
	60 STORE("nl:"+n, 0)
	70 STORE("nr:"+n, 0)
	80 RETURN n
End Function

Function deleteNode(n Uint64)
	10 DELETE("np:"+n)
	20 DELETE("nk:"+n)
	30 DELETE("nd:"+n)
	40 DELETE("nl:"+n)
	50 DELETE("nr:"+n)
	60 RETURN
End Function

Function btGetFirst(root Uint64) Uint64
	10 DIM n, l AS Uint64
	20 LET n = root
	30 IF LOAD("nk:"+n) != 0 THEN GOTO 50
	40 RETURN 0
	50 LET l = LOAD("nl:"+n)
	60 IF l == 0 THEN GOTO 90
	70 LET n = l
	80 GOTO 50
	90 RETURN n
End Function

Function btGetLast(root Uint64) Uint64
	10 DIM n, r AS Uint64
	20 LET n = root
	30 IF LOAD("nk:"+n) != 0 THEN GOTO 50
	40 RETURN 0
	50 LET r = LOAD("nr:"+n)
	60 IF r == 0 THEN GOTO 90
	70 LET n = r
	80 GOTO 50
	90 RETURN n
End Function

Function btGetNext(n Uint64) Uint64
	10 DIM r, p AS Uint64
	20 IF n == 0 THEN GOTO 90
	30 LET r = LOAD("nr:"+n)
	40 IF r == 0 THEN GOTO 60
	50 RETURN btGetFirst(r)
	60 LET p = LOAD("np:"+n)
	70 IF p == 0 THEN GOTO 90
	80 IF LOAD("nl:"+p) != n THEN GOTO 100
	90 RETURN p
	100 LET n = p
	110 GOTO 60
End Function

Function btGetPrev(n Uint64) Uint64
	10 DIM l, p AS Uint64
	20 IF n == 0 THEN GOTO 90
	30 LET l = LOAD("nl:"+n)
	40 IF l == 0 THEN GOTO 60
	50 RETURN btGetLast(l)
	60 LET p = LOAD("np:"+n)
	70 IF p == 0 THEN GOTO 90
	80 IF LOAD("nr:"+p) != n THEN GOTO 100
	90 RETURN p
	100 LET n = p
	110 GOTO 60
End Function

Function btFindNode(n Uint64, k Uint64) Uint64
	10 DIM nk, n1, l, r AS Uint64
	20 IF k == 0 THEN GOTO 180
	30 LET nk = LOAD("nk:"+n)
	40 IF nk != k THEN GOTO 100
	50 LET n1 = btGetPrev(n)
	60 IF LOAD("nk:"+n1) != k THEN GOTO 90
	70 LET n = n1
	80 GOTO 50
	90 RETURN n
	100 LET l = LOAD("nl:"+n)
	110 IF l == 0 || nk < k THEN GOTO 140
	120 LET n = l
	130 GOTO 30
	140 LET r = LOAD("nr:"+n)
	150 IF r == 0 THEN GOTO 180
	160 LET n = r
	170 GOTO 30
	180 RETURN 0
End Function

Function btInsert(root Uint64, k Uint64, d String) Uint64
	10 DIM n, p, tk AS Uint64
	20 IF k != 0 THEN GOTO 40
	30 RETURN 0
	40 LET n = root
	45 LET tk = LOAD("nk:"+n)
	50 IF tk != 0 THEN GOTO 90
	60 STORE("nk:"+n, k)
	70 STORE("nd:"+n, d)
	80 RETURN n
	90 IF n == 0 THEN GOTO 200
	95 LET tk = LOAD("nk:"+n)
	100 LET p = n
	110 IF k >= tk THEN GOTO 140
	120 LET n = LOAD("nl:"+n)
	130 GOTO 90
	140 LET n = LOAD("nr:"+n)
	150 GOTO 90
	200 LET n = createNode(p, k, d)
	210 IF k >= tk THEN GOTO 240
	220 STORE("nl:"+p, n)
	230 RETURN n
	240 STORE("nr:"+p, n)
	250 RETURN n
End Function

Function btDelete(root Uint64, n Uint64) Uint64
	10 DIM l, r, p, n1, cn AS Uint64
	20 LET l = LOAD("nl:"+n)
	30 LET r = LOAD("nr:"+n)
	40 LET p = LOAD("np:"+n)
	50 IF l == 0 || r == 0 THEN GOTO 200
	60 LET n1 = btGetFirst(r)
	70 STORE("nk:"+n, LOAD("nk:"+n1))
	80 STORE("nd:"+n, LOAD("nd:"+n1))
	90 RETURN btDelete(root, n1)
	200 IF r == 0 THEN GOTO 225
	210 LET cn = r
	220 GOTO 300
	225 IF l == 0 THEN GOTO 250
	230 LET cn = l
	250 IF cn != 0 || p != 0 THEN GOTO 300
	260 STORE("nk:"+n, 0)
	270 STORE("nd:"+n, "")
	280 RETURN root
	300 IF p == 0 THEN GOTO 400
	310 IF LOAD("nl:"+p) == n THEN GOTO 340
	320 STORE("nr:"+p, cn)
	330 GOTO 350
	340 STORE("nl:"+p, cn)
	350 IF cn == 0 THEN GOTO 450
	360 STORE("np:"+cn, p)
	370 GOTO 450
	400 LET root = cn
	410 STORE("np:"+root, 0)
	450 deleteNode(n)
	500 RETURN root
End Function

// Testbench functions

Function Insert(key Uint64, data String) Uint64
	10 STORE("node", btInsert(LOAD("root"), key, data))
	20 RETURN 0
End Function

Function Delete(node Uint64) Uint64
	10 STORE("root", btDelete(LOAD("root"), node))
	20 RETURN 0
End Function

Function FindNode(key Uint64) Uint64
	10 STORE("node", btFindNode(LOAD("root"), key))
	20 RETURN 0
End Function

Function GetFirst() Uint64
	10 STORE("node", btGetFirst(LOAD("root")))
	20 RETURN 0
End Function

Function GetLast() Uint64
	10 STORE("node", btGetLast(LOAD("root")))
	20 RETURN 0
End Function

Function GetNext(node Uint64) Uint64
	10 STORE("node", btGetNext(node))
	20 RETURN 0
End Function

Function GetPrev(node Uint64) Uint64
	10 STORE("node", btGetPrev(node))
	20 RETURN 0
End Function

Function RandFill(n Uint64) Uint64
	10 DIM i, r AS Uint64
	20 IF i == n THEN GOTO 70
	30 LET r = RANDOM()
	40 btInsert(LOAD("root"), r, "Data=" + r)
	50 LET i = i + 1
	60 GOTO 20
	70 RETURN 0
End Function

Function DeleteAllForward() Uint64
	10 DIM root, node, n1 AS Uint64
	20 LET root = LOAD("root")
	30 LET node = btGetFirst(root)
	40 IF node == 0 THEN GOTO 90
	50 LET n1 = btGetNext(node)
	60 LET root = btDelete(root, node)
	70 LET node = n1
	80 GOTO 40
	90 STORE("root", root)
	100 RETURN 0
End Function

Function DeleteAllReverse() Uint64
	10 DIM root, node, n1 AS Uint64
	20 LET root = LOAD("root")
	30 LET node = btGetLast(root)
	40 IF node == 0 THEN GOTO 90
	50 LET n1 = btGetPrev(node)
	60 LET root = btDelete(root, node)
	70 LET node = n1
	80 GOTO 40
	90 STORE("root", root)
	100 RETURN 0
End Function

Function ScanForward() Uint64
	10 DIM node AS Uint64
	20 DIM output AS String
	30 LET node = btGetFirst(LOAD("root"))
	40 IF node == 0 THEN GOTO 80
	50 LET output = output + LOAD("nk:"+node) + "\n"
	60 LET node = btGetNext(node)
	70 GOTO 40
	80 STORE("output", output)
	90 RETURN 0
End Function

Function ScanReverse() Uint64
	10 DIM node AS Uint64
	20 DIM output AS String
	30 LET node = btGetLast(LOAD("root"))
	40 IF node == 0 THEN GOTO 80
	50 LET output = output + LOAD("nk:"+node) + "\n"
	60 LET node = btGetPrev(node)
	70 GOTO 40
	80 STORE("output", output)
	90 RETURN 0
End Function

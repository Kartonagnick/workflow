
'format: 2021y-06m-30d 00:00:01
'format: 2021-06-30 00:00:01
Function makeDateTime(text)

    arr = Split(text, " ")

    date_value = arr(0)
    time_value = arr(1)

    date_value = replace(date_value, "y", "")
    date_value = replace(date_value, "m", "")
    date_value = replace(date_value, "d", "")

'    wscript.echo "------------" & vbCrLf
'    wscript.echo "date: " & date_value & vbCrLf
'    wscript.echo "time: " & time_value & vbCrLf
'    wscript.echo "------------" & vbCrLf

    date_value = Split(date_value, "-")

'    wscript.echo "------------" & vbCrLf
'    wscript.echo "year: "  & date_value(0) & vbCrLf
'    wscript.echo "month: " & date_value(1) & vbCrLf
'    wscript.echo "day: "   & date_value(2) & vbCrLf
'    wscript.echo "------------" & vbCrLf

    d_stamp = DateSerial(date_value(0), date_value(1), date_value(2))
    t_stamp = TimeValue(time_value)
    stamp = d_stamp + t_stamp

    makeDateTime = stamp 
End Function

Function makePosix(from)
    makePosix = DateDiff("s", #1970-01-01 00:00:00#, from) 
End Function

Function TwoDigits(num)
    If(Len(num) = 1) Then
        TwoDigits = "0" & num
    Else
        TwoDigits = num
    End If
End Function

Function formatStamp(stamp)
    y   = Year(stamp)
    m   = TwoDigits(Month(stamp))    
    d   = TwoDigits(Day(stamp))
    h   = TwoDigits(Hour(stamp))
    min = TwoDigits(Minute(stamp))
    s   = TwoDigits(Second(stamp))
    formatStamp = y & "-" & m & "-" & d & " " & h & ":" & min & ":" & s
End Function

Sub printStamp(stamp)
    wscript.echo formatStamp(stamp) & vbCrLf
End Sub


function main
    set objArgs = WScript.Arguments

    if objArgs.Count <> 3 then
        wscript.echo "error: wrong number of arguments (expected 1)"
        wscript.quit 1
    end if

    beg_value = objArgs(0)
    end_value = objArgs(1)
    cnt_value = objArgs(2)

    b_stamp = makeDateTime(beg_value)
    e_stamp = makeDateTime(end_value)

    b_sec = makePosix(b_stamp)
    e_sec = makePosix(e_stamp)

    diff = e_sec - b_sec
    offset = diff / cnt_value

'   wscript.echo "beg: " & beg_value & " --> " & b_stamp & " --> " & b_sec & vbCrLf
'   wscript.echo "beg: " & end_value & " --> " & e_stamp & " --> " & e_sec & vbCrLf
'   wscript.echo "dif: " & diff & vbCrLf
'   wscript.echo "cnt: " & cnt_value & " --> " & offset & vbCrLf

    printStamp(b_stamp)
    for i = 1 to cnt_value - 2
        b_stamp = DateAdd("s", offset, b_stamp)
        printStamp(b_stamp)
    next
    printStamp(e_stamp)

end function 

main()

'call err.Raise(vbObjectError + 10, "checkArguments: ", "'ePATH_WORK_DIRECTORY' not exists")

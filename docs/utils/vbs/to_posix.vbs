
function main
    set objArgs = WScript.Arguments

    if objArgs.Count <> 1 then
        wscript.echo "error: wrong number of arguments (expected 1)"
        wscript.quit 1
    end if

   'SetLocale(1106) 'Set to United Kingdom
   'WScript.Echo CDate("01/09/2017")   d/m/y

    src = objArgs(0)
'   wscript.echo "src: " & src & vbCrLf

    arr = Split(src, " ")
    date_value = arr(0)
    time_value = arr(1)

'    wscript.echo "------------" & vbCrLf
'    wscript.echo "date: " & date_value & vbCrLf
'    wscript.echo "time: " & time_value & vbCrLf
'    wscript.echo "------------" & vbCrLf

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

'    wscript.echo "------------" & vbCrLf
'    wscript.echo "d_stamp: "  & d_stamp & vbCrLf
'    wscript.echo "t_stamp: "  & t_stamp & vbCrLf
'    wscript.echo "stamp: "    & stamp   & vbCrLf
'    wscript.echo "------------" & vbCrLf

     from_date = #1970-01-01 00:00:00#
     to_date   = stamp
     result = DateDiff("s", from_date, to_date)
     wscript.echo result & vbCrLf
end function 

main()
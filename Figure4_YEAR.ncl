begin
a=addfile("/home/luomin/draw1/drylands/ntos_data/cru_station.nc","r")
c=addfile("/home/luomin/draw1/drylands/ntos_data/gpcp_station.nc","r")
d=addfile("/home/luomin/draw1/drylands/ntos_data/cmap_station.nc","r")
e=addfile("/home/luomin/draw1/drylands/ntos_data/merra2_station.nc","r")
f=addfile("../INTEGRATED_station.nc","r")
g = addfile("/home/luomin/draw1/drylands/ntos_data/pre_drylands_station_839.nc","r")
h=addfile("/home/luomin/draw1/drylands/ntos_data/gpm_station.nc","r")
;*********************
;*****************************************
precr=a->pre
precg=c->pre
precc=d->pre
precm=e->pre
precj=f->pre
precs=g->pre
precs=precs/10
precgp=h->pre
;******************************************
data=new((/7,40/),"float")
data1=new((/7,40/),"float")
prem=new((/303/),"float")
tid1=new((/303/),"integer")
tid1=g->stid
lat=g->lat
lon=g->lon
pre=g->pre
;printVarSummary(spre)
time=g->time
prem=dim_avg_n(pre,1)
nlat=dimsizes(lat)
nlon=dimsizes(lon)
time1=ispan(1980, 2019,1)
;************************
  precrm=dim_avg_n(precr,0) ;cru
  precgm=dim_avg_n(precg,0)  ;gpcp
  preccm=dim_avg_n(precc,0)  ;cmap
  precmm=dim_avg_n(precm,0)  ;merra
  precsm=dim_avg_n(precs,0)  ;obs
  precjm=dim_avg_n(precj,0)  ;merg
  precgpm=dim_avg_n(precgp,0) ;gpm
;*******************************
  yprec=new((/40/),"float")
  ypreg=new((/40/),"float")
   yprea=new((/40/),"float")
   yprem=new((/40/),"float")
  ypres=new((/40/),"float")
  yprej=new((/40/),"float")
  ypregp=new((/19/),"float")
;******************************
do i=0,39
   yprec(i)=dim_avg_n(precrm(i*12:(i+1)*12-1),0) ;cru
   ypreg(i)=dim_avg_n(precgm(i*12:(i+1)*12-1),0) ;gpcp
   yprea(i)=dim_avg_n(preccm(i*12:(i+1)*12-1),0) ;cmap
   yprem(i)=dim_avg_n(precmm(i*12:(i+1)*12-1),0) ;mear
   ypres(i)=dim_avg_n(precsm(i*12:(i+1)*12-1),0) ;obs
   yprej(i)=dim_avg_n(precjm(i*12:(i+1)*12-1),0) ;merg
end do
do i=0,18
    ypregp(i)=dim_avg_n(precgpm(i*12:(i+1)*12-1),0) ;gpm
end do
;**************************calculate w
data(0,:)= runave_n_Wrap(yprec,3,0,0);cru
data(1,:)= runave_n_Wrap(ypreg,3,0,0);gpcp
data(2,:)= runave_n_Wrap(yprea,3,0,0);cmap
data(3,:)= runave_n_Wrap(yprem,3,0,0);mera
data(4,:)= runave_n_Wrap(ypres,3,0,0);obs
data(5,:)= runave_n_Wrap(yprej,3,0,0);inte
data(6,21:39)=runave_n_Wrap(ypregp,3,0,0);gpm
;********************
  rc_t = regline(time1, yprec)
  data1(0,:)=rc_t*time1+rc_t@yintercept
  tval = rc_t@tval   ;t-statistic

  rc_t2 = regline(time1, ypreg)
 data1(1,:)=rc_t2*time1+rc_t2@yintercept
   tval2 = rc_t2@tval   ;t-statistic

  rc_t3 = regline(time1, yprea)
  data1(2,:)=rc_t3*time1+rc_t3@yintercept
  tval3 = rc_t3@tval   ;t-statistic

  rc_t4 = regline(time1, yprem)
  data1(3,:)=rc_t4*time1+rc_t4@yintercept
   tval4 = rc_t4@tval   ;t-statistic

  rc_t5 = regline(time1, ypres)
  data1(4,:)=rc_t5*time1+rc_t5@yintercept
   tval5 = rc_t5@tval   ;t-statistic

  rc_t6 = regline(time1, yprej)
  data1(5,:)=rc_t6*time1+rc_t6@yintercept
   tval6 = rc_t6@tval   ;t-statistic

  rc_t7 = regline(time1(21:39), ypregp)
  data1(6,21:39)=rc_t7*time1(21:39)+rc_t7@yintercept
   tval7 = rc_t7@tval   ;t-statistic

;************************************
data!0="num"
data!1="time"
data&time=time1
data1!0="num"
data1!1="time"
data1&time=time1
;*******************************
 plot=new(4,graphic)
wks   = gsn_open_wks ("eps","Figure4a") 
 res                   = True                      ; plot mods desired
   res@gsnDraw            = False             ; don't draw yet
  res@gsnFrame           = False             ; don't advance frame yet
   res@vpHeightF = 0.40        ; Changes the aspect ratio
  res@vpWidthF  = 0.65
  res@vpXF      = 0.10        ; change start locations
  res@vpYF      = 0.75        ; the plot
  res@txFont   = "helvetica"
  res@tmXBLabelFont="helvetica"
  res@tmYLLabelFont="helvetica"
  res@gsnLeftStringFontHeightF= 0.02
  res@tmXBLabelFontHeightF  = 0.02   ;x轴刻度字体大小
  res@tmYLLabelFontHeightF  = 0.02
  res@gsnLeftString       = "(a) Annual precipitation"
  res@xyDashPatterns =(/0,0,0,0,0,0,0,0/)
    res@trYMaxF           =  60                    ; axis max
  res@trYMinF           =   20                   ; axis min
 res@xyLineThicknesses = (/  2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0/)          ; make second line thicker
 res@xyLineColors      = (/"blue","red","goldenrod2","deepskyblue2","black","green","LightCoral"/)          ; change line color

 plot(0)  = gsn_csm_xy (wks,time1,data,res) ; create plot
 res@xyDashPatterns =(/16,16,16,16,16,16,16,16/)
 plot(1)  = gsn_csm_xy (wks,time1,data1,res)
    overlay(plot(0),plot(1))
;********************************************************
;**************************************
  res_text                    = True                  ; text mods desired
  res_text@txFontHeightF      = 0.02                 ; change text size
  res_text@txJust             = "CenterLeft"          ; text justification
  res_text@txFont="helvetica"

  res_lines                   = True                  ; polyline mods desired
  res_lines@gsLineDashPattern = 0.                    ; solid line
  res_lines@gsLineThicknessF  = 5.                    ; line thicker
  res_lines@gsLineColor       = "blue"                 ; line color
  res_lines@gsLineLabelFont="helvetica"
  xx = (/1981,1985/)
  yy = (/58,58/)
  dum3 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
  dum4 = gsn_add_text(wks,plot(0),"CRU",1986,58,res_text); add text
    text1=sprintf("%3.2f",rc_t)
  dum19 = gsn_add_text(wks,plot(0),text1,1991,58,res_text)


  yy = (/55,55/)
  res_lines@gsLineColor       = "red"                                 ; change to blue
  dum5 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)                ; add polyline
  dum6 = gsn_add_text(wks,plot(0),"GPCP",1986,55,res_text)       ; add text
      text2=sprintf("%3.2f",rc_t2)
  dum20 = gsn_add_text(wks,plot(0),text2,1991,55,res_text)

    yy = (/52,52/)
  res_lines@gsLineColor       = "goldenrod2"                                ; change to blue
  dum7 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)                ; add polyline
  dum8 = gsn_add_text(wks,plot(0),"CMAP",1986,52,res_text)       ; add text
      text3=sprintf("%3.2f",rc_t3)
 dum21 = gsn_add_text(wks,plot(0),text3,1991,52,res_text)

;  xx = (/1992,1996/)
  yy = (/49,49/)
   res_lines@gsLineColor       = "deepskyblue2"
  dum9 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
  dum10 = gsn_add_text(wks,plot(0),"MERRA2",1986,49,res_text); add text
       text4=sprintf("%3.2f",rc_t4)
  dum22 = gsn_add_text(wks,plot(0),text4,1994,49,res_text)

  xx = (/2001,2005/) 
  yy = (/58,58/)
   res_lines@gsLineColor       = "black"
  dum11 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
  dum12 = gsn_add_text(wks,plot(0),"OBS.",2006,58,res_text); add text
        text5=sprintf("%3.2f",rc_t5)
  dum23 = gsn_add_text(wks,plot(0),text5,2012,58,res_text)

     yy = (/55,55/)
   res_lines@gsLineColor       = "green"
  dum13 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
  dum14 = gsn_add_text(wks,plot(0),"INTE.",2006,55,res_text); add text
          text6=sprintf("%3.2f",rc_t6)
  dum24 = gsn_add_text(wks,plot(0),text6,2012,55,res_text)


   yy = (/52,52/)
   res_lines@gsLineColor       = "LightCoral"
  dum15 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
  dum16 = gsn_add_text(wks,plot(0),"GPM",2006,52,res_text); add text
  text7=sprintf("%3.2f",rc_t7)
 dum25 = gsn_add_text(wks,plot(0),text7,2012,52,res_text)


;**********************************************************
    plres= True
 plres@gsnPanelRowSpec=True
 gsn_panel(wks,plot,(/2,1/),plres)

  draw(plot)
  frame(wks)



end


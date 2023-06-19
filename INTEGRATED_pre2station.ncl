load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/luomin/test/shapefile_utils.ncl"

begin
;************************
a = addfile("INTEGRATED_PRE.nc","r")
b = addfile("/home/luomin/draw1/drylands/ntos_data/pre_drylands_station.nc","r")
data1=a->pre
time=ispan(1,480,1)
 lat=a->lat  ;116
 lon=a->lon  ;300
 lat@units = "degrees_north"
 lon@units = "degrees_east"
 nlat=dimsizes(lat)
 nlon=dimsizes(lon)
 nnum=480
  printVarSummary(data1)
;***********************************
prem=new((/303/),"float")
stid1=new((/303/),"integer")
stid1=b->stid
slat=b->lat
slon=b->lon
spre=b->pre
printVarSummary(spre)

stime=b->time
prem=dim_avg_n(spre,1)
nslat=dimsizes(slat)
nslon=dimsizes(slon)
;*******************************
;*********************************calculate stations
   scmap=new((/nslat,nnum/),float) 
    do i=0,nnum-1
      do j= 0, nslat-1
          y=floattoint((slat(j)-29.12264)/0.1957)
          x=floattoint((slon(j)-70.13897)/0.1994)
          scmap(j,i)=(data1(i,y,x)+data1(i,y+1,x)+data1(i,y,x+1)+data1(i,y+1,x+1))/4.0
      end do
    end do
;**************************************
    sn=ispan(1,303,1)
    stid1!0="sn"
    stid1&sn=sn

    slat!0="sn"
    slat&sn=sn                                          ;纬度也以1-839排序
    slat@units = "degree"
    slat@long_name = "Current Latitude of Corresponding Station"
    slon!0="sn"
    slon&sn=sn                                         ;纬度也以1-839排序
    slon@units = "degree"
    slon@long_name = "Current Longitude of Corresponding Station"

    scmap!0="sn"
    scmap!1="time"
    scmap&time=stime
    scmap&sn=sn
    scmap@long_name = " Observation of 839 Station in China"
    scmap@units = "mm/month"
    scmap@_FillValue = 32766
    scmap@statistic = "Monthly Mean"
  print(j)
  prem@_FillValue=32766
;**********************************************
 ;**************************************************************************
;********************write nc file
 outfile="INTEGRATED_station.nc"
 system("rm -f " + outfile)
 fout=addfile(outfile,"C") 
 fout->stid=stid1 
 fout->lon = slon 
 fout->lat = slat 
 fout->time =stime
 fout->pre=scmap
;**************************************
end


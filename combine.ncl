begin
a=addfile("/home/luomin/draw1/drylands/ntos_data/cru_station.nc","r")
b=addfile("/home/luomin/draw1/drylands/ntos_data/gpcp_station.nc","r")
c=addfile("/home/luomin/draw1/drylands/ntos_data/cmap_station.nc","r")
d=addfile("/home/luomin/draw1/drylands/ntos_data/merra2_station.nc","r")
e =addfile("/home/luomin/draw1/drylands/ntos_data/gpm_station.nc","r")
f = addfile("/home/luomin/draw1/drylands/ntos_data/pre_drylands_station_839.nc","r")
;***********************************  
;********************Different Reanalysis
precr=a->pre
precg=b->pre
precc=c->pre
precm=d->pre
precgp=e->pre
spre=f->pre
;******************************************
ave1=avg(precr(:,0:251));1980-2000
ave2=avg(precg(:,0:251))
ave3=avg(precc(:,0:251))
ave4=avg(precm(:,0:251))
;******************************************
ave8=avg(precr(:,252:479));2001-2019
ave9=avg(precg(:,252:479))
ave10=avg(precc(:,252:479))
ave11=avg(precm(:,252:479))
ave12=avg(precgp)
;***********************************
prem=new((/303/),"float")
stid1=new((/303/),"integer")
stid1=f->stid
slat=f->lat
slon=f->lon
spre=f->pre
spre=spre/10
stime=f->time
prem=dim_avg_n(spre(:,0:251),1)
nslat=dimsizes(slat)
nslon=dimsizes(slon)
ave6=avg(prem)
prem1=dim_avg_n(spre(:,252:479),1)
ave7=avg(prem1)
;*********************************************
d1=ave1-ave6
d2=ave2-ave6
d3=ave3-ave6
d4=ave4-ave6
;*******************************************
d6=ave8-ave7
d7=ave9-ave7
d8=ave10-ave7
d9=ave11-ave7
d10=ave12-ave7

;********************************************
ra1=abs(1/d1+1/d3)
ra2=abs(1/d2+1/d4)
rb1=abs(1/(d1+d3))
rb2=abs(1/(d2+d4))

w1=abs(1/d1)/ra1*rb1/(rb1+rb2)
w2=abs(1/d2)/ra2*rb2/(rb1+rb2)
w3=abs(1/d3)/ra1*rb1/(rb1+rb2)
w4=abs(1/d4)/ra2*rb2/(rb1+rb2)
;*****************************************
ra3=abs(1/d6)
ra4=abs(1/d7+1/d8+1/d9+1/d10)
rb3=abs(1/d6)
rb4=abs(1/(d7+d8+d9+d10))

w5=0.5
w6=abs(1/d7)/ra4*0.5
w7=abs(1/d8)/ra4*0.5
w8=abs(1/d9)/ra4*0.5
w9=abs(1/d10)/ra4*0.5
;********************************Reading different precipitation products which have the same spato-temporal resolutions
g=addfile("/home/luomin/pdata/303/pre_base.nc","r")
f1=addfile("/home/luomin/CRU/CRU_drylands_fine.nc","r")
f2=addfile("/data/luomin/NOAA/fine_drylands/GPCP_drylands_fine.nc","r")
f3=addfile("/data/luomin/NOAA/fine_drylands/CMAP_drylands_fine.nc","r")
f4=addfile("/data/luomin/NOAA/fine_drylands/MERRA2_drylands_fine.nc","r")
f5=addfile("/home/luomin/GPM/GPM_drylands_fine.nc","r")
pbase=g->pre 
pbase=pbase/10
pcru=f1->pre
pgpcp=f2->pre
pgpcp=pgpcp*30
pcmap=f3->pre
pcmap=pcmap*30
pmerra=f4->pre
pgpm=f5->pre
;********************************Creating integrated precipitation product
prej=new((/480,900,1800/),"float")
prein=new((/480,116,300/),"float")
pbasem1=new((/900,1800/),"float")
pbasem2=new((/900,1800/),"float")

pbasem1=dim_avg_n_Wrap(pbase(0:251,:,:),0)
pbasem2=dim_avg_n_Wrap(pbase(252:479,:,:),0)
;*********************************************************
 nlat22 = 900
 nlon22 = 1800
 lat22 = fspan(-88.75,88.75,nlat22)
 lon22 = fspan(-180,180,nlon22)
 lat22@units = "degrees_north"
 lon22@units = "degrees_east"
 time=ispan(1,480,1)
 pcru!0      = "time"
 pcru!1      = "lat"
 pcru!2      = "lon"
 pcru&lat    = lat22
 pcru&lon    = lon22
 pcru&time=time
 pcru@_FillValue=9.96921e+36
 copy_VarCoords(pcru,pgpcp)
 copy_VarCoords(pcru,pcmap)
 copy_VarCoords(pcru,pmerra)
 pgpm!0      = "time"
 pgpm!1      = "lat"
 pgpm!2      = "lon"
 pgpm&lat    = lat22
 pgpm&lon    = lon22
;***********************************************************
;  do j=0,251
;      prej(j,:,:)=w1*(pcru(j,:,:)-pbasem1(:,:))+w2*(pgpcp(j,:,:)-pbasem1(:,:))+w3*(pcmap(j,:,:)-pbasem1(:,:))+w4*(pmerra(j,:,:)-pbasem1(:,:))+pbasem1(:,:)
;  end do

 do j=0, 251
        prej(j,:,:)=w1*pcru(j,:,:)+w2*pgpcp(j,:,:)+w3*pcmap(j,:,:)+w4*pmerra(j,:,:)
 end do

;*****************************
;  do j=252,479  
;  prej(j,:,:)=w5*(pcru(j,:,:)-pbasem2(:,:))+w6*(pgpcp(j,:,:)-pbasem2(:,:))+w7*(pcmap(j,:,:)-pbasem2(:,:))+w8*(pmerra(j,:,:)-pbasem2(:,:))+w9*(pgpm(j-252,:,:)-pbasem2(:,:))+pbasem2(:,:)
;  end do
     
  do j=252,479
               prej(j,:,:)=w5*pcru(j,:,:)+w6*pgpcp(j,:,:)+w7*pcmap(j,:,:)+w8*pmerra(j,:,:)+w9*pgpm(j-252,:,:)
 end do

;**************************************
 nlat = 900
 nlon = 1800
 lat = fspan(-88.75,88.75,nlat)
 lon = fspan(-180,180,nlon)
 lat@units = "degrees_north"
 lon@units = "degrees_east"

    prej!0="time"
    prej!1="lat"
    prej!2="lon"
    prej&time=stime
    prej&lat=lat
    prej&lon=lon
    prej@units = "mm/month"
    prej@_FillValue = 32766
    prej@statistic = "Monthly Mean"
printVarSummary(prej)
;**********************************************
 prein=prej(:,{29:52},{70:130})
 printVarSummary(prein)
 lat1= fspan(29.12264,51.82842,116)
 lon1= fspan(70.13897,129.9722,300)
 lat1@units = "degrees_north"
 lon1@units = "degrees_east"
    prein!0="time"
    prein!1="lat"
    prein!2="lon"
    prein&time=stime
    prein&lat=lat1
    prein&lon=lon1
    prein@units = "mm/month"
    prein@_FillValue = 32766
    prein@statistic = "Monthly Mean"

;**************************************************************************
;********************write nc file
 outfile="INTEGRATED_PRE.nc"
 system("rm -f " + outfile)
 fout=addfile(outfile,"C")
 fout->lon=lon1
 fout->lat=lat1
 fout->time=stime
 fout->pre=prein
end

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/luomin/test/shapefile_utils.ncl"

begin
;************************
a = addfile("/data/luomin/NOAA/precip.1979-2019.mon.mean.2.5x2.5.GPCP.nc","r")
 data1=a->precip(12:491,:,:);1980-2013
 time=ispan(1,480,1)
 lat=a->lat
 lon=a->lon
 lat@units = "degrees_north"
 lon@units = "degrees_east"
 nlat=dimsizes(lat)
 nlon=dimsizes(lon)
 nnum=480
 data1    = lonFlip( data1 )
;*******************************************************
 lat11 = fspan(-88.75,88.75,nlat)
 lon11 = fspan(-180,180,nlon)
 lat11@units = "degrees_north"
 lon11@units = "degrees_east"
 data1!0      = "time"
 data1!1      = "lat"
 data1!2      = "lon"
 data1&lat    = lat11
 data1&lon    = lon11
 data1@_FillValue=-9.96921e+36

 nlat22 = 900
 nlon22 = 1800
 lat22 = fspan(-88.75,88.75,nlat22)
 lon22 = fspan(-180,180,nlon22)
 lat22@units = "degrees_north"
 lon22@units = "degrees_east"
 data=linint2_Wrap(lon11,lat11,data1,True,lon22,lat22,0)
 data!0      = "time"
 data!1      = "lat"
 data!2      = "lon"
 data&lat    = lat22
 data&lon    = lon22
 data@_FillValue=-9.96921e+36
 print("Step1ok!!!!!!!!!!!!!")
 delete(data1)
;*******************************************************
 ; 中国干旱区域
 sname = "/home/luomin/shp/drylands/arid_area/arid_area_line.shp"
 print_shapefile_info(sname)
 plot_shapefile(sname)
   minlon =  73.40
   maxlon =  126.53
   minlat =   30.50
   maxlat =   50.83
      udims = dimsizes(data)
      opt             = True
      opt@return_mask = True
      opt@minlon      = minlon     ; Makes the shapefile masking
      opt@maxlon      = maxlon     ; go faster.
      opt@minlat      = minlat
      opt@maxlat      = maxlat
   data_drylands=new((/nnum,nlat22,nlon22/),float)
   do i=0,nnum-1
     data_drylands(i,:,:) = shapefile_mask_data(data(i,:,:),sname,opt)
    end do
      data_drylands!0      = "time"
      data_drylands!1      = "lat"
      data_drylands!2      = "lon"
      data_drylands&lat    = lat22
      data_drylands&lon    = lon22
      data_drylands@_FillValue=-9.96921e+36
  print("Step2ok!!!!!!!!!!!!!")
;---Create masked data array
   premask = where(data_drylands.eq.1,data,data@_FillValue)
   copy_VarMeta(data,premask)
;****Creat .nc output
 premask!0      = "time"
 premask!1      = "lat"
 premask!2      = "lon"
 premask&lat    = lat22
 premask&lon    = lon22
 premask&time=time
 lat@units = "degrees_north"
 lon@units = "degrees_east"
 premask@_FillValue=-9.96921e+36
 print("Step3ok!!!!!!!!!!!!!")
 ;********************write nc file
 outfile="GPCP_drylands_fine.nc"
 system("rm -f " + outfile)
 fout=addfile(outfile,"C")
 fout->pre=premask
 print("Step4ok!!!!!!!!!!!!!")
;****************************************
  wks = gsn_open_wks("pdf","pre-gpcp")               ; send graphics to PNG file
  plot=new(1,graphic)
  res = True                                    ; plot mods desired
  res@cnFillOn             = True               ; turn on color fill
  cmap = read_colormap_file("WhiteBlueGreenYellowRed")
  res@cnLinesOn                   = False
  res@cnFillOn                    = True
  res@cnFillPalette               = cmap(15:,:)
  res@mpFillOn                    = False
  res@mpGeophysicalLineColor      = "Grey18"
  res@mpGeophysicalLineThicknessF = 1.5
  res@gsnAddCyclic                = False
 res@tmXBLabelsOn=True
 res@mpMinLonF            = 70.              ; set min lon
 res@mpMaxLonF            =  130.               ; set max lon
 res@mpMinLatF            =  25.               ; set min lat
 res@mpMaxLatF            =  55.               ; set min lat
  res@tiMainString         = " "

   res@gsnRightString       = " "
  res@gsnLeftString        =" "
  plot(0) = gsn_csm_contour_map(wks,premask(0,:,:), res)      ; create plot
   gsn_panel(wks,plot,(/1,1/),False)

end


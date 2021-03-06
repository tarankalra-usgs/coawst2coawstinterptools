clear all; close all; clc ;
%    This code creates boundary for a COAWST grid that is refined
%    based on an existing COAWST coarse grid solution 
%    The refined grid is nested within coarse grid. 
% 
% SCAT INTERP WITH FUNCTION REPLACEMENT  and MODULARITY 
%
% input -> 
% coarse grid -> grid_name_outer
% solution    -> ncml link
% refined grid -> grid_name_inner
%
% Solution 
% output -> boundary forcing file 
% 
%
% bry file includes zeta, ubar, vbar, sand, salt, temp
%
% This is currently set up to use opendap and nctoolbox.
%
% written by 05/20/2020 by Tarandeep S Kalra
% Adapted from Maitane Olabarrieta and Christie Heggermiller edits

% Define filenames.
% model_url : outer grid simulations
%mdl_fname = 'http://geoport.whoi.edu/thredds/dodsC/sand/usgs/users/tk
%mdl_fname='http://geoport.whoi.edu/thredds/dodsC/sand/usgs/users/tkalra/bbleh/1_30/bbleh.ncml';

setup_nctoolbox;
%mdl_fname='http://geoport.whoi.edu/thredds/dodsC/vortexfs1/usgs/users/tkalra/Output_bbleh_ew/bbleh.ncml';
mdl_fname='http://geoport.whoi.edu/thredds/dodsC/vortexfs1/usgs/users/tkalra/Output_bbleh_turb/bbleh.ncml';

nc = ncgeodataset(mdl_fname);
echo off 

grid_name_outer = '/media/taran/DATADRIVE2/marsh_result/barnegat_bay/all_other_folders/runfiles_bbleh_zd_taran/grid/bbleh_grid_073d.nc';

% Original forcing file
% MODIFY the existing forcing file
%srcFile='reedy_bry_north_test.nc';
%srcFile='reedy_bry_May1_May31.nc'; 
srcFile='reedy_bry_north_test_june.nc';
dstFile='reedy_bry_north_test_june_westappend2.nc';

% enter date of starting the run 
%dstart=datenum(2015,05,01);
dstart=datenum(2015,05,31);

t_insec(:)=nc{'ocean_time'}(:);
t_indays(:)=t_insec(:)/(3600*24);
% Converting time in days to julian time units;
t(:)=t_indays(:) +dstart;

% The time period for which the TPAR files need to be generated
%t1=datenum(2015,05,01);
t1=datenum(2015,05,31);
t2=datenum(2015,06,30);
%t1=datenum(2015,05,31);
%t2=datenum(2015,06,30); % , 01, 00, 00);

init_1=near(t,t1);
init_end=near(t,t2);

time=t_insec(init_1:init_end);


% These are grid parameters for the outer grid/bigger grid
% READ GRID PARAMETERS
coarse_masku = nc{'mask_u'}(:);
coarse_maskv = nc{'mask_v'}(:);
coarse_maskr = nc{'mask_rho'}(:);
angler = ncread(grid_name_outer,'angle');
angler = angler'; % Take the transpose of angler to be consistent for nc;
coarse_h = nc{'h'}(:);
coarse_Vtransform = nc{'Vtransform'}(:);
coarse_Vstretching = nc{'Vstretching'}(:);
coarse_hc = nc{'hc'}(:);
coarse_theta_s = nc{'theta_s'}(:);
coarse_theta_b = nc{'theta_b'}(:);
coarse_N = length(nc{'s_rho'}(:));
%
% This is lon and lat of the outer grid/biger grid saved 
%  
g = nc{'zeta'}(1,:,:).grid;
lon_rho = g.lon;
lat_rho = g.lat;
[nx ny]=size(lon_rho); 
grid_size_coarse=nx*ny;
%
% This is lon and lat of the outer grid/biger grid saved 
%  
lon_rho_coarse_3d=repmat(lon_rho,1,1,coarse_N);
lat_rho_coarse_3d=repmat(lat_rho,1,1,coarse_N);

close(nc);

%%%%%%%%%%%%%INNER/REFINED GRID%%%%%%%%%%%%%%%%%%%%%%%%%%
% These are grid parameters for the refined grid/inner grid
% gridname : refined grid
grid_name_inner = '/media/taran/DATADRIVE2/marsh_result/barnegat_bay/easygrid/myfile_29_datum_20cm.nc';
% initial name for refined grid that is user input v
% bathymetry name for refined grid that is user input 
%bry_fname=  'reedy_bry_east.nc';

% These parameters are for the refined/inner grid 
% Enter grid vertical coordinate parameters
% These need to be consistent with the refined ROMS setup.
theta_s = 0.0;
theta_b = 0.0;
Tcline  = 0;
ref_N   = 7;
Vtransform  = 1;
Vstretching = 1;

disp('getting roms grid dimensions ...');

Sinp.N           = ref_N;            % number of vertical levels
Sinp.Vtransform  = Vtransform;   % vertical transformation equation
Sinp.Vstretching = Vstretching;  % vertical stretching function
Sinp.theta_s     = theta_s;      % surface control parameter
Sinp.theta_b     = theta_b;      % bottom  control parameter
Sinp.Tcline      = Tcline;       % surface/bottom stretching width

if Vtransform == 1
    h = ncread(grid_name_inner,'h');
    hmin = min(h(:));
    hc = min(max(hmin,0),Tcline);
elseif Vtransform == 2
    h = ncread(grid_name_inner,'h');
    hmin = max(0.1,min(h(:)));
    hc = Tcline;
end

 % inputs pertaining to refined grids 
Sinp.hc = hc;                          % stretching width used in ROMS
gn = get_roms_grid(grid_name_inner,Sinp);
[nx_ref,ny_ref] = size(gn.lon_rho);
grid_size_ref=nx_ref*ny_ref       ;
%
% This is lon and lat of the outer grid/biger grid saved 
%  
lon_rho_ref_3d=repmat(gn.lon_rho,1,1,ref_N);
lat_rho_ref_3d=repmat(gn.lat_rho,1,1,ref_N);
zr_ref=gn.z_r; 
angle_ref=gn.angle;


% this is required for calculation of water level 
report=0;

tic
% 
% for scattered interolant convert arrays into 1 d vector
%Reshape all the data in column vector
% COARSE 
lon_rho_coarse_col=reshape(lon_rho,[grid_size_coarse 1]);
lat_rho_coarse_col=reshape(lat_rho,[grid_size_coarse 1]); 
lon_rho_coarse_3d_col=reshape(lon_rho_coarse_3d,.........
                             [grid_size_coarse*coarse_N 1]);
lat_rho_coarse_3d_col=reshape(lat_rho_coarse_3d,.........
                             [grid_size_coarse*coarse_N 1]); 

% REFINED 
lon_rho_ref_col   =reshape(gn.lon_rho,[grid_size_ref 1]);
lat_rho_ref_col   =reshape(gn.lat_rho,[grid_size_ref 1]); 
lon_rho_ref_3d_col=reshape(lon_rho_ref_3d,.........
                             [grid_size_ref*ref_N 1]);
lat_rho_ref_3d_col=reshape(lat_rho_ref_3d,.........
                             [grid_size_ref*ref_N 1]); 

load('4dvar_bbleh_coarse.mat','F_4d_coarse'); 
load('3dvar_bbleh_coarse.mat','F_3d_coarse')

% Setting the arrays and loop through time 
for mm = init_1:init_end
  try 
    nc = ncgeodataset(mdl_fname);
    zeta_coarse(:,:) = double(squeeze(nc{'zeta'}(mm,:,:)));
    zeta_coarse=squeeze(zeta_coarse(:,:));
    
% Compute vertical elevations of the grid, this is time dependent
    zr_coarse = set_depth(coarse_Vtransform, coarse_Vstretching, ....
                   coarse_theta_s,    coarse_theta_b, .....
                   coarse_hc,         coarse_N,.........
                   5,                 coarse_h, zeta_coarse, report);
           
% interpolate using scatteredinterpolation 
    zeta_coarse(~coarse_maskr) = NaN;
    zeta_coarse = maplev(zeta_coarse); 
    
    v_3d=zeta_coarse; 
    [zz]=interp3d_insert_tsk(lon_rho_coarse_col, lat_rho_coarse_col, v_3d, ...
                              F_3d_coarse, lon_rho_ref_col, lat_rho_ref_col, .....
                             nx_ref, ny_ref );
                         
%interpolate on the refined mesh F_3d_coarse was saveed for zeta so no change

% Hardwired for western bc (1,:)
    zeta_ref(:,mm-init_1+1)=zz(1,:); 

    clear zz 
%reshape back to the 3D array 
    
    % 3D- Velocities ubar and vbar to be moved to cell centers
    ubar_coarse(:,:)=double(squeeze(nc{'ubar'}(mm,:,:)));
    au = ubar_coarse;
    au(~coarse_masku) = NaN;
    au = maplev(au);
    %au = au.*coawst_hu;
    aur = u2rho_2d_mai(au);

    vbar_coarse(:,:)=double(squeeze(nc{'vbar'}(mm,:,:)));
    av = vbar_coarse;
    av(~coarse_maskv) = NaN;
    av = maplev(av);
    %av = av.*coawst_hv;
    avr = v2rho_2d_mai(av);

    % Compute northward and eastward velocities, important!
    vel = aur + avr.*sqrt(-1);
    vel = vel .* exp(sqrt(-1)*angler);
    velu = real(vel);
    velv = imag(vel);

     % Replace zeta with velu 
    grd_size=length(lon_rho_coarse_col);

    v_3d=velu ; 
%Reshape all the data in column vector 
    velu1=interp3d_insert_tsk(lon_rho_coarse_col, lat_rho_coarse_col, v_3d, ...
                              F_3d_coarse, lon_rho_ref_col, lat_rho_ref_col, .....
                             nx_ref, ny_ref ) ;
    clear v_3d 

     % Replace zeta with velv 
    v_3d=velv ; 
%Reshape all the data in column vector 
    velv1=interp3d_insert_tsk(lon_rho_coarse_col, lat_rho_coarse_col, v_3d, ...
                             F_3d_coarse, lon_rho_ref_col, lat_rho_ref_col, .....
                             nx_ref, ny_ref ) ;
    clear v_3d 
     
% Rotate velocities to ROMS grid, important!
% These are grid(angle_ref) parameters for the outer grid/bigger grid
    ubar1 = velu1.*cos(angle_ref)+velv1.*sin(angle_ref);
    vbar1 = velv1.*cos(angle_ref)-velu1.*sin(angle_ref);
     
    disp('times when this code has executed')
    mm-init_1+1

% This will be ubar, vbar for refined mesh (convert from rho to u, v points)

% hardwired for northern obc
    %ubar2(:)=squeeze(ubar1(:,end));
    %vbar2(:)=squeeze(vbar1(:,end)); 
    ubar2=rho2u_2d_mw(ubar1);  % defined at u points
    vbar2=rho2v_2d_mw(vbar1);
    
%western 
    ubar_ref(:,mm-init_1+1)=ubar2(1,:); 
    vbar_ref(:,mm-init_1+1)=vbar2(1,:); 
%     
%     disp('vbar1 size')
%    size(vbar1)
  % stop
   
   clear zeta zeta_coarse ubar_coarse vbar_coarse
   clear vel au av aur avr velu velv velu1 velv1 ubar1 vbar1
   clear ubar2 vbar2 
% PROCEED TO 4D variables
% These are grid(nc temp) parameters for the outer grid/bigger grid
%    temp_coarse=double(squeeze(nc{'temp'}(mm,:,:,:)));
%    salt_coarse=double(squeeze(nc{'salt'}(mm,:,:,:)));
%    sand01_coarse=double(squeeze(nc{'sand_01'}(mm,:,:,:)));
    sand02_coarse=double(squeeze(nc{'sand_02'}(mm,:,:,:)));
    sand03_coarse=double(squeeze(nc{'sand_03'}(mm,:,:,:)));
    sand04_coarse=double(squeeze(nc{'sand_04'}(mm,:,:,:)));
    sand05_coarse=double(squeeze(nc{'sand_05'}(mm,:,:,:)));
    u_coarse=double(squeeze(nc{'u'}(mm,:,:,:)));
    v_coarse=double(squeeze(nc{'v'}(mm,:,:,:)));
%
% % 4d vars (maplev)
%
   [sand02_tmp_coarse, sand03_tmp_coarse, .....
    sand04_tmp_coarse, sand05_tmp_coarse, .....
    u2_tmp_coarse, v2_tmp_coarse, zr_coarse]=maplev_4dvar_tsk(....
                 sand02_coarse, sand03_coarse, ......
                 sand04_coarse, sand05_coarse, .......
                 u_coarse, v_coarse, zr_coarse, .....
                 coarse_N,.....
                 coarse_maskr, coarse_masku, coarse_maskv);
       
%  % Calculate the "u" velocity that is staggered on rho points.
    for zz = 1:coarse_N
       ur_coarse(:,:,zz) = u2rho_2d_mai(u2_tmp_coarse(:,:,zz));
       vr_coarse(:,:,zz) = v2rho_2d_mai(v2_tmp_coarse(:,:,zz));
    end
% % Compute Northward and Eastward velocities, angler is the angle for big grid
    for zz = 1:coarse_N
       vel = squeeze(ur_coarse(:,:,zz))+squeeze(vr_coarse(:,:,zz)).*sqrt(-1);
       vel = vel.* exp(sqrt(-1) * angler);
       ur_tmp_coarse(:,:,zz) = real(vel);
       vr_tmp_coarse(:,:,zz) = imag(vel);
    end

    clear ur_coarse vr_coarse u2_tmp_coarse v2_tmp_coarse
    clear temp_coarse salt_coarse
    clear sand01_coarse sand02_coarse sand03_coarse
    clear sand04_coarse sand05_coarse
    clear u_coarse v_coarse

% Store zr in 1 d array to be sent to interp functions 
    zr_coarse_3d_col=reshape( zr_coarse(:,:,1:coarse_N), ...
                             [grid_size_coarse*coarse_N 1] ) ; 

    zr_ref_3d_col   =reshape( zr_ref(:,:,1:ref_N), ....
                             [grid_size_ref*ref_N 1] ); 

% 
   % temp
%   f_4d=temp_tmp_coarse; 
%   [temp_tmp_ref]=interp4d_insert_tsk(lon_rho_coarse_3d_col, lat_rho_coarse_3d_col,...
%                                  zr_coarse_3d_col, .....
%                                  f_4d, F_4d_coarse,.....
%                                  lon_rho_ref_3d_col, lat_rho_ref_3d_col, ....
%                                  zr_ref_3d_col, .....
%                                  nx_ref, ny_ref, ref_N);
%                  

   % salt 
%   f_4d=salt_tmp_coarse; 
%   [salt_tmp_ref]=interp4d_insert_tsk(lon_rho_coarse_3d_col, lat_rho_coarse_3d_col,...
%                                  zr_coarse_3d_col, .....
%                                  f_4d, F_4d_coarse,.....
%                                  lon_rho_ref_3d_col, lat_rho_ref_3d_col, ....
%                                  zr_ref_3d_col, .....
%                                  nx_ref, ny_ref, ref_N);
%    % sand01
%     f_4d=sand01_tmp_coarse; 
%     [sand01_tmp_ref]=interp4d_insert_tsk(lon_rho_coarse_3d_col, lat_rho_coarse_3d_col,...
%                                   zr_coarse_3d_col, .....
%                                   f_4d, F_4d_coarse,.....
%                                   lon_rho_ref_3d_col, lat_rho_ref_3d_col, ....
%                                   zr_ref_3d_col, .....
%                                   nx_ref, ny_ref, ref_N);
   % sand02
    f_4d=sand02_tmp_coarse; 
    [sand02_tmp_ref]=interp4d_insert_tsk(lon_rho_coarse_3d_col, lat_rho_coarse_3d_col,...
                                  zr_coarse_3d_col, .....
                                  f_4d, F_4d_coarse,.....
                                  lon_rho_ref_3d_col, lat_rho_ref_3d_col, ....
                                  zr_ref_3d_col, .....
                                  nx_ref, ny_ref, ref_N);
    % sand03				  
    f_4d=sand03_tmp_coarse; 
    [sand03_tmp_ref]=interp4d_insert_tsk(lon_rho_coarse_3d_col, lat_rho_coarse_3d_col,...
                                  zr_coarse_3d_col, .....
                                  f_4d, F_4d_coarse,.....
                                  lon_rho_ref_3d_col, lat_rho_ref_3d_col, ....
                                  zr_ref_3d_col, .....
                                  nx_ref, ny_ref, ref_N);
    % sand04
    f_4d=sand04_tmp_coarse; 
    [sand04_tmp_ref]=interp4d_insert_tsk(lon_rho_coarse_3d_col, lat_rho_coarse_3d_col,...
                                  zr_coarse_3d_col, .....
                                  f_4d, F_4d_coarse,.....
                                  lon_rho_ref_3d_col, lat_rho_ref_3d_col, ....
                                  zr_ref_3d_col, .....
                                  nx_ref, ny_ref, ref_N);

    % sand05
    f_4d=sand05_tmp_coarse; 
    [sand05_tmp_ref]=interp4d_insert_tsk(lon_rho_coarse_3d_col, lat_rho_coarse_3d_col,...
                                  zr_coarse_3d_col, .....
                                  f_4d, F_4d_coarse,.....
                                  lon_rho_ref_3d_col, lat_rho_ref_3d_col, ....
                                  zr_ref_3d_col, .....
                                  nx_ref, ny_ref, ref_N);
   %u_4d
    f_4d=ur_tmp_coarse; 
    [ur_tmp_ref]=interp4d_insert_tsk(lon_rho_coarse_3d_col, lat_rho_coarse_3d_col,...
                                  zr_coarse_3d_col, .....
                                  f_4d, F_4d_coarse,.....
                                  lon_rho_ref_3d_col, lat_rho_ref_3d_col, ....
                                  zr_ref_3d_col, .....
                                  nx_ref, ny_ref, ref_N);
   % v_4d
    f_4d=vr_tmp_coarse; 
    [vr_tmp_ref]=interp4d_insert_tsk(lon_rho_coarse_3d_col, lat_rho_coarse_3d_col,...
                                  zr_coarse_3d_col, .....
                                  f_4d, F_4d_coarse,.....
                                  lon_rho_ref_3d_col, lat_rho_ref_3d_col, ....
                                  zr_ref_3d_col, .....
                                  nx_ref, ny_ref, ref_N);

    % Rotate velocities to ROMS grid, important!, gn.angle is angle for refined grid
    for zz = 1:coarse_N
        ur2_ref(:,:,zz) = squeeze(ur_tmp_ref(:,:,zz)).*cos(angle_ref) + .....
                          squeeze(vr_tmp_ref(:,:,zz)).*sin(angle_ref);
        vr2_ref(:,:,zz) = squeeze(vr_tmp_ref(:,:,zz)).*cos(angle_ref) -.....
                          squeeze(ur_tmp_ref(:,:,zz)).*sin(angle_ref);
        u_tmp_ref(:,:,zz) = rho2u_2d_mw(ur2_ref(:,:,zz));  % defined at u points
        v_tmp_ref(:,:,zz) = rho2v_2d_mw(vr2_ref(:,:,zz));  % defined at v points
    end
    

% temp_4d is the refined/inner grid
%    temp_4d(:,:,:,mm-init_1+1)=double(temp_tmp_ref(:,:,:));
%    salt_4d(:,:,:,mm-init_1+1)=double(salt_tmp_ref(:,:,:));
%    sand01_4d(:,:,:,mm-init_1+1)=double(sand01_tmp_ref(:,:,:));

% Hardwired to save western obc
% 

    sand02_4d(:,:,mm-init_1+1)=double(sand02_tmp_ref(1,:,:));
    sand03_4d(:,:,mm-init_1+1)=double(sand03_tmp_ref(1,:,:));
    sand04_4d(:,:,mm-init_1+1)=double(sand04_tmp_ref(1,:,:));
    sand05_4d(:,:,mm-init_1+1)=double(sand05_tmp_ref(1,:,:));
    u_4d(:,:,mm-init_1+1)=double(u_tmp_ref(1,:,:)) ;
    v_4d(:,:,mm-init_1+1)=double(v_tmp_ref(1,:,:)) ;

    clear ur_tmp_ref vr_tmp_ref ur2_ref vr2_ref
    clear temp_tmp_coarse salt_tmp_coarse
    clear sand01_tmp_coarse sand02_tmp_coarse sand03_tmp_coarse 
    clear sand04_tmp_coarse sand05_tmp_coarse
    clear ur_tmp_coarse vr_tmp_coarse
    
  catch ME
    disp(['could not get that data at ', mdl_fname])
  end 
end
 

% store temp and salt as with the size of sand but zero values
% HACKS for the marsh growth model
% make sand01=0.0 ;
sand01_4d=sand02_4d*0.0; 
% make sand02 concentration to double ; which is the marsh eroded class
sand02_4d=sand02_4d*2 ; 
temp_4d=sand02_4d.*0.0;
salt_4d=temp_4d; 


%Introduce point for reedy grid interpolation that has the same value of
%temp and salinity on the northern boundary 

load('tempsalt_May_jul_reedy.mat','temp_1d_tsk_north', 'salt_1d_tsk_north',....
                                    'temp_1d_tsk_east', 'salt_1d_tsk_east',.....
				    'temp_1d_tsk_west', 'salt_1d_tsk_west'); % this is value of temperature and salinity at a point 
% Have fetched the data from Zafer's solution
% ------------------
% |                 |
% |                 |
% temp1             |
% salt1             |
% |-----------------|

for mm = init_1:init_end
   tt=mm-init_1+1;
   for k = 1:coarse_N
     temp_4d(1:ny_ref,k,tt)=temp_1d_tsk_west(k,tt); 
     salt_4d(1:ny_ref,k,tt)=salt_1d_tsk_west(k,tt); 
   end 
end 

				    
% store local counters
count_1=1;
count_end=init_end-init_1+1 ; 

%
% Chose the open bc that needs to be forced
% obc.north=true;
% obc.south=true;
%obc.north=0;
%obc.south=0;
%obc.west=0;
obc.west=1; 

netcdf_load(srcFile);

x_psi = 133 ;
x_rho = 134 ;
x_u = 133 ;
x_v = 134 ;
e_psi = 389 ;
e_rho = 390 ;
e_u = 390 ;
e_v = 389 ;
s_rho = 7 ;

zeta_time =count_end ;
v2d_time = count_end;
v3d_time = count_end;
salt_time = count_end;
temp_time = count_end;
sand_time =count_end ;

copyfile(srcFile,dstFile);
fileattrib(dstFile,'+w');
ncid = netcdf.open(dstFile,'WRITE');
%
% Convert the 4d array names into west 
[zeta_west,ubar_west,vbar_west,temp_west,salt_west,......
          u_west, v_west, sand_west_01, sand_west_02, .....
          sand_west_03, sand_west_04, sand_west_05]=...........
      save_westbc(obc, zeta_ref, ubar_ref, vbar_ref, u_4d, v_4d, .....
temp_4d, salt_4d, .....
sand01_4d, sand02_4d, sand03_4d, sand04_4d, sand05_4d,count_1,count_end);

% append to the file 
create_append_roms_west(x_psi, x_rho, x_u, x_v, e_psi, e_rho, e_u, ....
e_v, s_rho, zeta_time, zeta_west, ubar_west, vbar_west, u_west, v_west, temp_west, salt_west, .....
sand_west_01, sand_west_02, sand_west_03, sand_west_04, sand_west_05, dstFile);

 

toc 

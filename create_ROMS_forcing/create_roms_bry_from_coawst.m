function create_roms_from_coawst(grid_file,bry_file,bry_time,...
    theta_s,theta_b,Tcline,Vtransform,Vstretching,N,...
    zeta_north, ubar_north, vbar_north,...
    temp_north, salt_north, u_north, v_north, .....
    sand_north_01, sand_north_02, sand_north_03, sand_north_04, .....
    sand_north_05,......
    zeta_south, ubar_south, vbar_south,...
    temp_south, salt_south, u_south, v_south, .....
    sand_south_01, sand_south_02, sand_south_03, sand_south_04, .....
    sand_south_05,......
    zeta_east, ubar_east, vbar_east,...
    temp_east, salt_east, u_east, v_east, .....
    sand_east_01, sand_east_02, sand_east_03, sand_east_04, .....
    sand_east_05,......
    zeta_west, ubar_west, vbar_west,...
    temp_west, salt_west, u_west, v_west, .....
    sand_west_01, sand_west_02, sand_west_03, sand_west_04, .....
    sand_west_05, obc )

% Create a netcdf file that contains baoundary data for ROMS
% zeta, ubar and vbar.

h=ncread(grid_file,'h');
hmin=min(h(:));
hc=min([hmin,Tcline]);
[LP,MP]=size(h);
L  = LP-1;
M  = MP-1;
xi_psi  = L;
xi_rho  = LP;
xi_u    = L;
xi_v    = LP;
eta_psi = M;
eta_rho = MP;
eta_u   = MP;
eta_v   = M;
%
% These are just copied from above, and then we call get_roms_grid.
%
Sinp.N           =N;            %number of vertical levels
Sinp.Vtransform  =Vtransform;   %vertical transformation equation
Sinp.Vstretching =Vstretching;  %vertical stretching function
Sinp.theta_s     =theta_s;      %surface control parameter
Sinp.theta_b     =theta_b;      %bottom  control parameter
Sinp.Tcline      =Tcline;       %surface/bottom stretching width
Sinp.hc          =hc;           %stretching width used in ROMS
%
Gout=get_roms_grid(grid_file,Sinp);

%create boundary file --> notice the length(bry_time)
create_roms_netcdf_bndry_mwUL(bry_file,Gout,length(bry_time),obc)

%now write the data from the arrays to the netcdf file
disp(' ## Filling Variables in netcdf file with data...')

%SCook's way
%ncwrite(bry_file,'bry_time',bry_time);
ncwrite(bry_file,'zeta_time',bry_time);
ncwrite(bry_file,'v2d_time',bry_time);
ncwrite(bry_file,'v3d_time',bry_time);
ncwrite(bry_file,'salt_time',bry_time);
ncwrite(bry_file,'temp_time',bry_time);
ncwrite(bry_file,'sand_time',bry_time);

if(obc.north==1)
    disp('north')
ncwrite(bry_file,'zeta_north',zeta_north);
ncwrite(bry_file,'ubar_north',ubar_north);
ncwrite(bry_file,'vbar_north',vbar_north);
ncwrite(bry_file,'temp_north',temp_north);
ncwrite(bry_file,'salt_north',salt_north);
ncwrite(bry_file,'u_north',u_north);
ncwrite(bry_file,'v_north',v_north);

ncwrite(bry_file,'sand_north_01',sand_north_01);
ncwrite(bry_file,'sand_north_02',sand_north_02);
ncwrite(bry_file,'sand_north_03',sand_north_03);
ncwrite(bry_file,'sand_north_04',sand_north_04);
ncwrite(bry_file,'sand_north_05',sand_north_05);
end
if(obc.south==1)
        disp('south')
ncwrite(bry_file,'zeta_south',zeta_south);
ncwrite(bry_file,'ubar_south',ubar_south);
ncwrite(bry_file,'vbar_south',vbar_south);
ncwrite(bry_file,'temp_south',temp_south);
ncwrite(bry_file,'salt_south',salt_south);
ncwrite(bry_file,'u_south',u_south);
ncwrite(bry_file,'v_south',v_south);

ncwrite(bry_file,'sand_south_01',sand_south_01);
ncwrite(bry_file,'sand_south_02',sand_south_02);
ncwrite(bry_file,'sand_south_03',sand_south_03);
ncwrite(bry_file,'sand_south_04',sand_south_04);
ncwrite(bry_file,'sand_south_05',sand_south_05);
end
if(obc.east==1)
        disp('east')
ncwrite(bry_file,'zeta_east',zeta_east);
ncwrite(bry_file,'ubar_east',ubar_east);
ncwrite(bry_file,'vbar_east',vbar_east);
ncwrite(bry_file,'temp_east', temp_east);
ncwrite(bry_file,'salt_east', salt_east);
ncwrite(bry_file,'u_east' ,u_east);
ncwrite(bry_file,'v_east',v_east);

ncwrite(bry_file,'sand_east_01',sand_east_01);
ncwrite(bry_file,'sand_east_02',sand_east_02);
ncwrite(bry_file,'sand_east_03',sand_east_03);
ncwrite(bry_file,'sand_east_04',sand_east_04);
ncwrite(bry_file,'sand_east_05',sand_east_05);
end
if(obc.west==1)
        disp('west')
ncwrite(bry_file,'zeta_west',zeta_west);
ncwrite(bry_file,'ubar_west',ubar_west);
ncwrite(bry_file,'vbar_west',vbar_west);
ncwrite(bry_file,'temp_west', temp_west);
ncwrite(bry_file,'salt_west', salt_west);
ncwrite(bry_file,'u_west' ,u_west);
ncwrite(bry_file,'v_west',v_west);
% 
ncwrite(bry_file,'sand_west_01', sand_west_01);
ncwrite(bry_file,'sand_west_02', sand_west_02);
ncwrite(bry_file,'sand_west_03', sand_west_03);
ncwrite(bry_file,'sand_west_04', sand_west_04);
ncwrite(bry_file,'sand_west_05', sand_west_05);

end 
% ncwrite(clm_file,'u',u);
% ncwrite(clm_file,'v',v);
% ncwrite(clm_file,'temp',temp);
% ncwrite(clm_file,'salt',salt);


%close file
disp(['created ', bry_file])



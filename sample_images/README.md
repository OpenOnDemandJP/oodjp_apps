# Summary

| Name | Target | Where to get it | License |
| --- | --- | --- | --- |
| `gnuplot.dat` | Gnuplot | (Original) | Public Domain |
| `cluster.pdb` | ParaView, XCrySDen, PyMOL, VESTA, OVITO | `xcrysden-1.6.3-rc2/examples/PDB/cluster.pdb` | GNU |
| `sample.nc` | GrADS | (Developed by ChatGPT) | Public Domain |
| `curv2d.silo` | VisIt | `visit3_4_2.linux-x86_64/data/curv2d.silo` | BSD |
| `simple_test.smv` | Smokeview | Create from `FDS/FDS6/Examples/Fires` | Public Domain |
| `ImageJ.png` | ImageJ | https://imagej.net/ij/images/ | Public Domain |

# Memo
## `sample.nc`
```bash
$ cat << EOF > sample.cdl
netcdf sample {
dimensions:
    time = 2 ;
    lat = 3 ;
    lon = 4 ;

variables:
    double time(time) ;
        time:units = "hours since 2000-01-01 00:00:00" ;
        time:calendar = "standard" ;

    double lat(lat) ;
        lat:units = "degrees_north" ;

    double lon(lon) ;
        lon:units = "degrees_east" ;

    float temp(time, lat, lon) ;
        temp:units = "K" ;

data:
 time = 0, 6 ;

 lat = 30, 35, 40 ;
 lon = 130, 135, 140, 145 ;

 temp =
  280,281,282,283,
  284,285,286,287,
  288,289,290,291,

  281,282,283,284,
  285,286,287,288,
  289,290,291,292 ;
}
EOF

$ ncgen -o sample.nc sample.cdl
$ grads
ga> sdfopen sample.nc
ga> d temp
```

## `curv2d.silo`
1. Launch VisIt 
2. Click `Add` button -> `Boundary` -> `mat1`
3. Click `Draw` button

## `simple_test.smv`
1. Install FDS
2. Execute `mpiexec fds simple_test.fds` in `FDS/FDS6/Examples/Fires`

Please refer to https://www.hpci-office.jp/for_users/appli_software/appli_fds/fds_r-ccs_riken-2
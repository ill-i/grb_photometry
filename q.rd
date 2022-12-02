<resource schema="grb_photometry" resdir=".">
  <meta name="creationDate">2022-11-28T18:12:52Z</meta>

  <meta name="title">Photometrical observations of GRB</meta>
  <meta name="description">
    The database of Gamma Ray Burst (GRB) photometrical observations obtained on defferent telescopes at Fesenkov Astrophysical Institute, Almaty, Kazakhstan. Observations were carried out in the optical range.
  </meta>
  <!-- Take keywords from 
    http://www.ivoa.net/rdf/uat
    if at all possible -->
  <meta name="subject">gamma-ray-bursts</meta>

  <meta name="creator">Fesenkov Astrophysical Institute</meta>
  <meta name="instrument">AZT-20</meta>
  <meta name="instrument">Zeiss-1000 (East)</meta>
  <meta name="facility">Academician Omarov Assy-Turgen Observatory</meta>
  <meta name="facility">Tian Shan Astronomical Observatory</meta>

  <meta name="contentLevel">Research</meta>
  <meta name="type">Catalog</meta>  <!-- or Archive, Survey, Simulation -->

  <!-- Waveband is of Radio, Millimeter, 
      Infrared, Optical, UV, EUV, X-ray, Gamma-ray, can be repeated -->
  <meta name="coverage.waveband">Optical</meta>

  <table id="main" onDisk="True" mixin="//siap#pgs" adql="True">

    <!-- in the following, just delete any attribute you don't want to
    set.
    
    Get the target class, if any, from 
    http://simbad.u-strasbg.fr/guide/chF.htx -->
    <!--<mixin
      calibLevel="2"
      collectionName="'%a few letters identifying this data%'"
      targetName="%column name of an object designation%"
      expTime="%column name of an exposure time%"
      targetClass="'%simbad target class%'"
    >//obscore#publishSIAP</mixin>-->

    <column name="object" type="text"
      ucd="meta.id;src"
      tablehead="Obj."
      description="Object name"
      verbLevel="3"/>
    <column name="target_ra"
      unit="deg" ucd="pos.eq.ra;meta.main"
      tablehead="Target RA"
      description="Right ascension of an object."
      verbLevel="1"/>
    <column name="target_dec"
      unit="deg" ucd="pos.eq.dec;meta.main"
      tablehead="Target Dec"
      description="Declination of an object."
      verbLevel="1"/>
    <column name="exptime"
      unit="s" ucd="time.duration;obs.exposure"
      tablehead="T.Exp"
      description="Exposure time."
      verbLevel="5"/>
    <column name="telescope" type="text"
      ucd="instr.tel"
      tablehead="Telescope"
      description="Telescope."
      verbLevel="3"/>
    <column name="observat" type="text"
      ucd="instr.tel"
      tablehead="Observat"
      description="Observatory where data was obtained."
      verbLevel="3"/>
    
  </table>

  <coverage>
    <updater sourceTable="main"/>
  </coverage>

  <!-- if you have data that is continually added to, consider using
    updating="True" and an ignorePattern here; see also howDoI.html,
    incremental updating -->
  <data id="import">
    <sources pattern="data/*.fit"/>

    <!-- the fitsProdGrammar should do it for whenever you have
    halfway usable FITS files.  If they're not halfway usable,
    consider running a processor to fix them first – you'll hand
    them out to users, and when DaCHS can't deal with them, chances
    are their clients can't either -->
    <fitsProdGrammar>
      <rowfilter procDef="//products#define">
        <bind key="table">"\schema.main"</bind>
      </rowfilter>
    </fitsProdGrammar>

    <make table="main">
      <rowmaker>
        <simplemaps>
          exptime: EXPOSURE,
          telescope: TELESCOP,
          observat: OBSERVAT
        </simplemaps>
        
        <apply procDef="//procs#dictMap">
          <bind key="mapping">{
            "Sloan_r": "SDSS r",
          }</bind>
	  <bind key="key">"FILTER"</bind>
        </apply>

        <!-- put vars here to pre-process FITS keys that you need to
          re-format in non-trivial ways. -->
        <apply procDef="//siap#setMeta">
          <!-- DaCHS can deal with some time formats; otherwise, you
            may want to use parseTimestamp(@DATE_OBS, '%Y %m %d...') -->
          <bind key="dateObs">@DATE_OBS</bind>

          <!-- bandpassId should be one of the keys from
            dachs adm dumpDF data/filters.txt;
            perhaps use //procs#dictMap for clean data from the header. -->
          <bind key="bandpassId">@FILTER</bind>

          <!-- pixflags is one of: C atlas image or cutout, F resampled, 
            X computed without interpolation, Z pixel flux calibrated, 
            V unspecified visualisation for presentation only
          <bind key="pixflags"></bind>-->
        
    <bind key="title">"{} {} {}".format(@OBJECT, @DATE_OBS, @FILTER)</bind>
        </apply>

        <apply procDef="//siap#getBandFromFilter"/>

        <apply procDef="//siap#computePGS"/>

        <map key="target_ra">hmsToDeg(@OBJCTRA, sepChar=" ")</map>
        <map key="target_dec">hmsToDeg(@OBJCTDEC, sepChar=" ")</map>
        <map key="object">@OBJECT</map>

        <!-- any custom columns need to be mapped here; do *not* use
          idmaps="*" with SIAP -->
      </rowmaker>
    </make>
  </data>

  <!-- if you want to build an attractive form-based service from
    SIAP, you probably want to have a custom form service; for
    just basic functionality, this should do, however. -->
  
  <dbCore queriedTable="main" id="imagecore">
                <condDesc original="//siap#protoInput"/>
    <condDesc original="//siap#humanInput"/>
    <condDesc buildFrom="dateObs"/>
    <condDesc buildFrom="object"/>
  </dbCore>

  <service id="web" allowed="form" core="imagecore">
    <meta name="shortName">grb siap</meta>
    <meta name="title">Web interface to FAI GRB observations</meta>
    <outputTable autoCols="accref,accsize,centerAlpha,centerDelta,
                  dateObs,imageTitle">
      <outputField original="object"/>
    </outputTable>
  </service>

    
  <service id="i" allowed="form,siap.xml" core="imagecore">
    <meta name="shortName">grb siap</meta>

    <!-- other sia.types: Cutout, Mosaic, Atlas -->
    <meta name="sia.type">Pointed</meta>
    
    <meta name="testQuery.pos.ra">251.2</meta>
    <meta name="testQuery.pos.dec">72.3</meta>
    <meta name="testQuery.size.ra">0.1</meta>
    <meta name="testQuery.size.dec">0.1</meta>

    <!-- this is the VO publication -->
    <publish render="siap.xml" sets="ivo_managed"/>
    <!-- this puts the service on the root page -->
    <publish render="form" sets="local,ivo_managed"/>
    <!-- all publish elements only become active after you run
      dachs pub q -->
  </service>

  <regSuite title="grb_photometry regression">

    <regTest title="grb_photometry SIAP serves some data">
      <url POS="251.2,72.3" SIZE="0.1,0.1" dateObs="59107.7/"
        >i/siap.xml</url>
      <code>
        rows = self.getVOTableRows()
        self.assertEqual(len(rows), 1)
        row = rows[0]
        self.assertEqual(row["object"], "GRB200829A")
        self.assertEqual(row["imageTitle"],'GRB200829A 2020-09-15T17:22:21.24 SDSS r')
      </code>
    </regTest>

    <!-- add more tests: image actually delivered, form-based service
      renders custom widgets, etc. -->
  </regSuite>
</resource>

<template>
  <div class="visualization">
    <div id="title-container">
      <h1>Integrated Water Science Basins</h1>
      <p>The U.S. Geological Survey is addressing the Nation’s greatest water resource challenges through the intensive study of 10 Integrated Water Science (IWS) basins. The IWS basins will represent a wide range of environmental, hydrologic, and landscape settings and human stressors of water resources to improve understanding of water availability.</p>
    </div>
<!--     <CONUS id="conus-container" />
    <HUC id="huc-container" />
    <BarcodeChart id="chart" /> -->
    <chartGrid id="charts" />
  </div>
</template>

<script>
import * as d3Base from 'd3';
export default {
    name: 'Visualization',
    components: {
      chartGrid: () => import( /* webpackPreload: true */ /*webpackChunkName: "section"*/ "./../components/CONUS"),
      //HUC: () => import( /* webpackPreload: true */ /*webpackChunkName: "section"*/ "./../components/HUC"),
      //BarcodeChart: () => import( /* webpackPreload: true */ /*webpackChunkName: "section"*/ "./../components/BarcodeChart")
    },
    data() {
    return {
      publicPath: process.env.BASE_URL, // this is need for the data files in the public folder, this allows the application to find the files when on different deployment roots
      d3: null,

      // dimensions
      w: null,
      h: null,
      margin: { top: 50, right: 50, bottom: 50, left: 50 },
      barcode: null,
      map: null,

      iws_illinois: [712, 713],
      iws_delaware: [204],
      iws_upper_colorado: [1402, 1401],

    }
    },
    computed: {
    },
    mounted(){
      const self = this;
      this.d3 = Object.assign(d3Base);

      // chart elements
      this.barcode = this.d3.select(".barcode-chart")
      this.d3.selectAll(".bar")
        .attr("fill", "blue")
        .attr("stroke", "blue")
      this.map = this.d3.selectAll("path.huc8")
        .attr("z-index", 500)
        .attr("fill", "red")
        .on("mouseover", function(d, i) {
          console.log(d)
        })

      //this.addHover();
      
    },
    methods:{
      addHover(d, i){
        console.log(d)
        // when basin is hovered on map, highlight the data points in the barcodes
        //this.map
        //.attr()//

      }
    }
} 
</script>

<style lang="scss">
// color scale
$dark_blue: rgb(26, 62, 89);
$dark_purp:rgb(71, 9, 56);
$lite_blue:rgb(92, 148, 189);
$lite_purp: rgb(242, 214, 235); 

// color vars
$bkgd_color: rgb(49, 49, 49);
$text_color: white;
$hilite: $lite_blue;


// layout
#title-container {
  grid-area: title;
}
#charts {
  grid-area: chart;
  //background-color: rgb(0, 238, 255);
}
// mobile layout
.visualization {
  max-width: 1600px; // doing this so the first view everything fits on a laptop without numerous layouts
  margin: auto;
  display: grid;
  gap: 10px;
  grid-template-areas:
    "title"
    "chart";
}
// desktop
@media (min-width: 900px) {
  .visualization {
  margin: 5rem;
  display: grid;
  gap: 20px;
  grid-template-columns: 2fr 2fr;
  grid-template-areas:
    "title title"
    "chart chart";
}
}
</style>

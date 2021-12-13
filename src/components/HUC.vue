<template>
  <section> 
    <div id="card-container" />
    <!-- This filter div may mess up placement of other elements as is may need to adjust later -->
    <div>
      <svg>
        <filter
          id="shadow1"
          style="width: 0px; height:0px"
        >
          <feDropShadow
            dx="0"
            dy="0"
            stdDeviation="5"
            flood-color="#858585"
          />
        </filter>
      </svg>
    </div>
  </section>
</template>
<script>
import * as d3Base from 'd3';
export default {
  name: "HUC",
    components: {
    },
    data() {
    return {
      publicPath: process.env.BASE_URL, // this is need for the data files in the public folder, this allows the application to find the files when on different deployment roots
      d3: null,

      // dimensions
      width: null,
      height: null,
      margin: { top: 10, right: 10, bottom: 10, left: 10 },
      inner_margin: { top: 10, right: 10, bottom: 10, left: 10 },
      svg_card: null,
      svg_container: null,

    }
  },
  mounted(){      
      this.d3 = Object.assign(d3Base);

    // attempting to read in svg from url
      /* var new_svg = fetch('https://labs.waterdata.usgs.gov/visualizations/maps/map.svg')
        .then((response) => response.text())
        .then((text) => eval(text))
    console.log(new_svg)
     */

    // global items
    this.svg_container = document.querySelector('#card-container')
    this.width = 400//this.svg_container.offsetWidth; - had to change to get svg to draw
    this.height = 150//this.svg_container.offsetHeight; - had to change to get svg to draw
    
    // load data
    this.loadData();

    // resize chart when window changes 
    // window.addEventListener("resize", this.resize)

    },
    methods:{
        loadData(){
            // add data here
            const self = this;
            let promises = [
                // will need to read in csv w/ basin id, basin name, region name, and the key stats for the card
                // self.d3.csv([FILE], this.d3.autotype)
            ];
            Promise.all(promises).then(self.callback);
        },
        callback(data){
          // let csv_stats = data[0]

          // draw card
          this.drawCard();

          // populate card
          // PLACEHOLDER FUNCTION - will eventually by called by mouseover
          // and passed the basin id (will be used to get path)
          // and the stats data for that basin
          this.customizeCard();
        },
        resize(){
            // make chart responsive
           // var w = this.svg_container.clientWidth;
            //var h = this.svg_container.clientHeight;
        },
        drawCard(){
          const self = this

            // create svg for card
            this.svg_card = this.d3.select("#card-container")
                .append("svg")
                .classed("card svg-card", true)
                .attr("viewBox", "0 0 " + (this.width + this.margin.right + this.margin.left) + " " + (this.height + this.margin.top + this.margin.bottom))
                .attr("preserveAspectRatio", "xMidYMid meet")
                .attr("width", "100%")
                .attr("height", "100%")

            // append group and translate
            let card = this.svg_card.append("g")
              .attr("class", "card")
              .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")

            // add background rectangle
            card.append("rect")
              .attr("class", "bkgdRect")
              .attr("x", 0)
              .attr("y", 0)
              .attr("rx", 5)
              .attr("ry", 5)
              .attr("width", this.width)
              .attr("height", this.height)
              .attr("filter", "url(#shadow1)")
              .style("fill", "rgb(41, 41, 41)")
              .style("stroke", "#ffffff")
              .style("stroke-opacity", 0.2)
              .style("stroke-width", 0.5)

            // define variables to control placement of svg that will contain basin path
            let inset_x = this.width/2
            let inset_y = 15

            // Append group and translate
            let insetGroup = card.append("g")
                .classed("card insetMap", true)
                .attr("transform", "translate(" + inset_x + "," + this.inner_margin.top + ")")

            // Append svg that will hold basin path
            let cardInset = insetGroup.append("svg")
                .classed("card insetSVG", true)
                .attr("id", "inset_svg")
                .attr("width", (this.width/2 - this.inner_margin.right))
                .attr("height", (this.height - this.inner_margin.top - this.inner_margin.bottom))

            // Place card text
            // Variables controlling text vertical placement
            let text1_y = 20
            let text2_y = 50
            let text3_y = 90
            let text4_y = 110
            let text5_y = 130

            // Name of basin
            // text will eventually be populated on mouseover
            card.append("text")
              .attr("class", "basinName")
              .attr("id", "basin_name")
              .attr("x", this.inner_margin.left)
              .attr("y", text1_y + this.inner_margin.top)

            // Name of region that contains basin
            // text will eventually be populated on mouseover
            card.append("text")
              .attr("class", "regionName")
              .attr("id", "region_name")
              .attr("x", this.inner_margin.left)
              .attr("y", text2_y)

            // Stats titles
            card.append("text")
              .attr("class", "statTitle")
              .attr("x", this.inner_margin.left)
              .attr("y", text3_y)
              .text("Basin area (km²):")
            card.append("text")
              .attr("class", "statTitle")
              .attr("x", this.inner_margin.left)
              .attr("y", text4_y)
              .text("Mean annual temperature (°C):")
            card.append("text")
              .attr("class", "statTitle")
              .attr("x", this.inner_margin.left)
              .attr("y", text5_y)
              .text("Mean annual precipitation (mm):")

            // Stats
            // text will eventually be populated on mouseover
            card.append("text")
              .attr("class", "statValue")
              .attr("id", "basin_area")
              .attr("x", this.inner_margin.left + 95)
              .attr("y", text3_y)
            card.append("text")
              .attr("class", "statValue")
              .attr("id", "mean_temp")
              .attr("x", this.inner_margin.left + 168)
              .attr("y", text4_y)
            card.append("text")
              .attr("class", "statValue")
              .attr("id", "mean_ppt")
              .attr("x", this.inner_margin.left + 180)
              .attr("y", text5_y)
              
        },
        // PLACEHOLDER FUNCTION - will eventually by called by mouseover
        // and passed the basin id (will be used to get path)
        // and the stats data for that basin
        customizeCard() {
          const self = this
            // PLACEHOLDER
            // Will need to pass in #id of basin
            // Pull svg of basin, d attribute of path element, and bounding box (for translation)
            let basinPath = document.querySelectorAll("#iws_upper_colorado")[0]
            let basinPathCoords = basinPath.getAttribute("d")
            let pathBBOX = basinPath.getBBox()

            // set viewBox of svg based on path bounding box attributes, so scales nicely
            let cardInset = this.d3.select("#inset_svg")
                .attr("viewBox", "0 0 " + pathBBOX.width + " " + pathBBOX.height)
                .attr("preserveAspectRatio", "xMidYMid meet")

            // draw path and translate according to path bounding box
            cardInset.append("path")
              .attr("d", basinPathCoords)
              .attr("fill", "rgb(41, 41, 41)")
              .style("stroke", "#f1f1f1")
              .style("stroke-width", 0.5)
              .attr("transform", "translate(" + -pathBBOX.x + "," + -pathBBOX.y + ")")

            // populate titles
            // PLACEHOLDERS FOR NOW
            // will need to use actual data values
            // text will eventually be populated on mouseover
            this.d3.select("#basin_name")
              .text("Basin name")
            this.d3.select("#region_name")
              .text("Region name")

            // populate stats
            // PLACEHOLDERS FOR NOW
            // will need to use actual data values
            this.d3.select("#basin_area")
              .text("23,000")
            this.d3.select("#mean_temp")
              .text("8.9")
            this.d3.select("#mean_ppt")
              .text("2,022")
        } 
    }
}
</script>
<style scoped lang="scss">
$dark_blue: rgb(26, 62, 89);
$dark_purp:rgb(71, 9, 56);
$lite_blue:rgb(92, 148, 189);
$lite_purp: rgb(242, 214, 235); 
$bkgd_color: $dark_blue;
$text_color: $lite_purp;

// style card
#card-container {
  width: 100%;
  vertical-align: top;
  overflow: hidden;
}
.svg-card {
    display:inline-block;
    position: absolute;
    top:0;
    left:0;
}
</style>
<style lang="scss">
$card_text: #ffffff;
.basinName {
  color: $card_text;
  fill: $card_text;
  font-size: 1.5em;
}
.regionName {
  color: $card_text;
  fill: $card_text;
  font-size: 1em;
  font-style: italic;
}
.statTitle {
  color: $card_text;
  fill: $card_text;
  font-size: 0.8em;
  font-weight: 500;
}
.statValue {
  color: $card_text;
  fill: $card_text;
  font-size: 0.8em;
}
</style>
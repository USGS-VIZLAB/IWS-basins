<template>
  <section id="grid-container">
    <CONUSmap id="conus-map" />
    <div id="barcode-container" />
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
import CONUSmap from '@/assets/components/map.svg';
export default {
  name: "CONUS",
    components: {
        CONUSmap
    },
    data() {
    return {
      publicPath: process.env.BASE_URL, // this is need for the data files in the public folder, this allows the application to find the files when on different deployment roots
      d3: null,

      // dimensions
      w: null,
      h: null,
      width: null,
      height: null,
      margin: { top: 10, right: 10, bottom: 10, left: 10 },
      inner_margin: { top: 10, right: 10, bottom: 10, left: 10 },

    
      svg_map: null,
      svg_chart: null,
      svg_card: null,
      barcode_container: null,

    }
  },
  
  mounted(){      
    this.d3 = Object.assign(d3Base);

    // svg elements
    this.barcode_container = this.d3.select("#barcode-container")
    this.svg_map = this.d3.select("#conus-map")
    this.svg_container = document.querySelector('#card-container')

    // size to container
    this.w = document.getElementById("barcode-container").offsetWidth;
    this.h = document.getElementById("barcode-container").offsetHeight;
    // card dimensions
    this.width = 400//this.svg_container.offsetWidth; - had to change to get svg to draw
    this.height = 150
    
    // create svg that will hold barcode chart
    this.svg_barcode = this.d3.select("#barcode-container")
      .append("svg")
      .classed("barcode-chart", true)
      .attr("viewBox", "0 0 " + this.w + " " + this.h)
      .attr("preserveAspectRatio", "xMidYMid meet")

    this.loadData();

   // resize chart when window changes 
   // window.addEventListener("resize", this.drawChart)

    },
    methods:{
        loadData(){
            const self = this;

            // read in data
            let promises = [
                self.d3.csv("https://labs.waterdata.usgs.gov/visualizations/data/basin_water_use.csv", this.d3.autoType),
                self.d3.csv("https://labs.waterdata.usgs.gov/visualizations/data/basin_mapping.csv", this.d3.autoType)
            ];
            Promise.all(promises).then(self.callback);
        },
        callback(data){
          const self = this;

          // water use by basin - basin_id, tot_wu_mgd, tot_wu_percentile
          this.basin_wu = data[0];

          // mapping huc to basin
          this.basin_mapping = data[1];

           // draw card
          this.drawCard();

          // populate card
          // PLACEHOLDER FUNCTION - will eventually by called by mouseover
          // and passed the basin id (will be used to get path)
          // and the stats data for that basin
          this.customizeCard();

          // draw bacodes
          this.addBarcode(this.basin_wu)
        },
        addBarcode(data){
          // draw barcode strips
          this.drawChart(data, {
            x: d => d.tot_wu_mgd,
            x_name: d => 'Water use (mgd)',
            y_pos: 20,
            x_min: 0,
            var_class: 'wu'
          })

          this.drawChart(data, {
            x: d => d.ppt_change_mm,
            x_name: d => 'Change in precip (mm)',
            y_pos: 50,
            x_min: -150,
            var_class: 'ppt'
          })

          this.drawChart(data, {
            x: d => d['ur2012-1974'],
            x_name: d => 'Change in urban (%)',
            y_pos: 80,
            x_min: 0,
            var_class: 'urban'
          })

          this.drawChart(data, {
            x: d => d['ag2012-1974'],
            x_name: d => 'Change in agriculture (%)',
            y_pos: 110,
            x_min: 0,
            var_class: 'agriculture'
          })

          this.drawChart(data, {
            x: d => d['rarearea_perc'],
            x_name: d => 'Rare ecosystem (%)',
            y_pos: 140,
            x_min: 0,
            var_class: 'rare'
          })

          this.drawChart(data, {
            x: d => d['aq_animal_sar_mean'],
            x_name: d => 'Aquatic animal species (SAR)',
            y_pos: 170,
            x_min: 0,
            var_class: 'rare'
          })

          this.drawChart(data, {
            x: d => d['aq_plant_sar_mean'],
            x_name: d => 'Aquatic plant species (SAR)',
            y_pos: 200,
            x_min: 0,
            var_class: 'rare'
          })
          this.drawChart(data, {
            x: d => d['firehazard'],
            x_name: d => 'Fire hazard',
            y_pos: 230,
            x_min: 0,
            var_class: 'fire'
          })

          // add classes to IWS basins for interaction
           var iws_irb = "iws_illinois";
           var iws_ucol = "iws_upper_colorado";
           var iws_drb = "iws_delaware";

          // TODO: use basin to huc mapping to make more flexbile
           this.d3.selectAll(".basin_712")
             .classed(iws_irb, true)

           this.d3.selectAll(".basin_713")
             .classed(iws_irb, true)

           this.d3.selectAll(".basin_204")
             .classed(iws_drb, true)

            this.d3.selectAll(".basin_1402")
             .classed(iws_ucol, true)

            this.d3.selectAll(".basin_1401")
              .classed(iws_ucol, true)

          // trigger hover interaction with barcode
          this.hoverIWS();
        },
        drawChart(data, {
          //draws bacode chart given x variable inputs
          value = d => d, // convenience alias for x
          x = value, // given d in data, returns value
          type = this.d3.scaleLinear,
          x_name,
          x_min,
          y_pos,
          y_height = 16,
          var_class
        } = {}) {

          const x_start = 250;

          // x axis scale
          var xScale = type()
            .domain([x_min, this.d3.max(data, x)]).nice()
            .range([x_start, this.w-20])

          var xAxis = this.d3.axisTop(xScale)

          // there's too many variables - need to refine. also difficult to show more than one with different axes
          // should make generalized axes and then have true value shown in pop up?
          // use same scaling for percentages?
          this.svg_barcode.append("g")
            .attr("transform", "translate(" + 0 + ", " + y_pos + ")")
            .attr("class", "x-axis")
            /* .call(xAxis)
            .call(g => g.select(".domain")
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "white"))
            .call(g => g.selectAll(".tick line")
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "white")) */
            .call(g => g.append("text")
                .attr("x", 0)
                .attr("y", 10+y_height)
                .attr("font-size", "1rem")
                .attr("font-weight", 600)
                .attr("class", "x_label")
                .attr("fill", "currentColor")
                .attr("text-anchor", "start")
                .text(x_name));

          // draw barcode lines
          var svg_add = this.svg_barcode
            .append("g")
            .classed(var_class, true)

          svg_add
            .selectAll(".bar")
            .data(data, function(d) { return d.basin_id })
            .enter()
            .append("rect")
            .classed("bar", true)
            .attr("class", d => { return "bar basin_" + d.basin_id }) // to grab in interaction - 
            .attr("x", d => xScale(x(d)))
            .attr("y", y_pos+10)
            .attr("width", 2)
            .attr("height", y_height)
            .attr("opacity", 0.35)
            .attr("fill", "white")    

  
        },
        hoverIWS(){
           // add mouseover interaction to map using basin class
          this.d3.selectAll(".huc8")
              .attr("z-index", 500)
              .on("mouseover", function(d, i) {

          let basin;

          // TODO: use basin mapping to coordinate interaction between svgs

          if (i == '0') {
            basin = "iws_illinois"
            console.log("." + basin)
            this.svg_barcode
              .selectAll("rect." + basin)
              .attr("fill", "red")
          };
          if (i == '2') {
            basin = "iws_upper_colorado"
            console.log("rect." + basin)
            this.svg_barcode
              .selectAll("rect." + basin)
              .attr("fill", "red")
          };
          if (i == '1') {
            basin = "iws_delaware"
            console.log("rect." + basin)
            this.svg_barcode
              .selectAll("rect." + basin)
              .attr("fill", "red")
          }
    
         })
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
$hilite: rgb(208, 138, 223);
$electric_blue: rgb(93, 225, 248);

// style map
.state {
    z-index: -100;
}
.river {
    stroke: $electric_blue;
}
.order_6 {
    stroke-width: 2px;
}
.huc8 {
    z-index:100;
    stroke: $hilite;
    stroke-width: 2px;
}

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

// layout
#conus-container {
  grid-area: CONUS;
}
#card-container {
  grid-area: card;
}
#barcode-container {
  grid-area: chart;
  height: 22vh;
  //width: 100%;
}
// mobile layout
#grid-container {
  max-width: 1400px; // doing this so the first view everything fits on a laptop without numerous layouts
  margin: auto;
  display: grid;
  gap: 10px;
  grid-template-areas:
    "CONUS"
    "chart"
    "card";
}
// desktop
@media (min-width: 900px) {
  #grid-container {
  margin: auto;
  display: grid;
  gap: 20px;
  grid-template-columns: 1fr;
  grid-template-areas:
    "CONUS"
    "chart"
    "card";
}
}
</style>
<template>
  <section>
    <div id="barcode-container" />
    <p>The variables above represent some attributes considered in the selection of IWS basins. Use your mouse to explore stats for each basin. </p>
  </section>
</template>
<script>
import * as d3Base from 'd3';
export default {
  name: "BarcodeChart",
    components: {
    },
    data() {
    return {
      publicPath: process.env.BASE_URL, // this is need for the data files in the public folder, this allows the application to find the files when on different deployment roots
      d3: null,

      // dimensions
      w: null,
      h: null,
      margin: { top: 50, right: 50, bottom: 50, left: 50 },
      svg_chart: null,
      barcode_container: null,

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
    // make chart responsive
    this.barcode_container = this.d3.select("#barcode-container")
    this.w = document.getElementById("barcode-container").offsetWidth;
    this.h = document.getElementById("barcode-container").offsetHeight;
    
    // create svg that will hold chart
    this.svg_barcode = this.d3.select("#barcode-container")
      .append("svg")
      .classed("barcode-chart", true)
      .attr("viewBox", "0 0 " + this.w + " " + this.h)
      .attr("preserveAspectRatio", "xMidYMid meet")

    this.loadData();

    // resize chart when window changes 
    window.addEventListener("resize", this.drawChart)

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
        },
        resize(){
            // make chart responsive
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
            .attr("class", d => { return "bar basin_" + d.basin_id }) // to grab in interaction
            .attr("x", d => xScale(x(d)))
            .attr("y", y_pos+10)
            .attr("width", 2)
            .attr("height", y_height)
            .attr("opacity", 0.35)
            .attr("fill", "white")    

        }

    }
}
</script>
<style scoped lang="scss">
$hilite: rgb(208, 138, 223);
$electric_blue: rgb(93, 225, 248);

#barcode-container {
  height: 25vh;
  width: 100%;
}

</style>
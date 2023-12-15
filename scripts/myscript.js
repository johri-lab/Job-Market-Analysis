// add your JavaScript/D3 to this file
// Load CSV files
const rowConverter = function (d) {
  return {
    industry_text: d.industry_text,
    year: +d.year, // Convert year to a number
    hires: +d.Hires,
  };
};

// Global variable to store the selected industry
let selectedIndustry = null;

// Function to update the bar chart based on the selected industry
function updateChart(data) {
  const filteredData = data.filter(d => selectedIndustry === null || d.industry_text === selectedIndustry);

  const svg = d3.select("#plot");

  // Remove existing chart
  svg.selectAll("*").remove();

  // D3.js code for creating a bar chart with axes
  const margin = { top: 30, right: 30, bottom: 50, left: 60 };
  const width = 800 - margin.left - margin.right;
  const height = 500 - margin.top - margin.bottom;

  const newSvg = svg.append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  const xScale = d3.scaleBand()
    .domain(filteredData.map(d => d.year.toString()))
    .range([0, width])
    .padding(0.1);

  const yScale = d3.scaleLinear()
    .domain([0, d3.max(filteredData, d => d.hires)])
    .range([height, 0]);

  // Add X axis
  newSvg.append("g")
    .attr("transform", "translate(0," + height + ")")
    .call(d3.axisBottom(xScale))
    .append("text")
    .attr("x", width / 2)
    .attr("y", margin.bottom - 10)
    .attr("dy", "0.71em")
    .attr("fill", "#000")
    .text("Year");

  // Add Y axis
  newSvg.append("g")
    .call(d3.axisLeft(yScale))
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", -margin.left + 15)
    .attr("x", -height / 2)
    .attr("dy", "0.71em")
    .attr("fill", "#000")
    .text("Hires");

  // Draw bars for each year
  newSvg.selectAll(".bar")
    .data(filteredData)
    .enter().append("rect")
    .attr("class", "bar")
    .attr("x", d => xScale(d.year.toString()))
    .attr("width", xScale.bandwidth())
    .attr("y", d => yScale(d.hires))
    .attr("height", d => height - yScale(d.hires))
    .attr("fill", "steelblue");
}

// Function to handle dropdown changes
function dropdownChange() {
  selectedIndustry = document.getElementById("industryDropdown").value;

  // Call the updateChart function with the filtered data
  updateChart(window.data);
}

// Function to populate dropdown options
function populateDropdownOptions(data) {
  const industries = [...new Set(data.map(d => d.industry_text))];

  const industryDropdown = document.getElementById("industryDropdown");

  industries.forEach(industry => {
    const option = document.createElement("option");
    option.value = industry;
    option.text = industry;
    industryDropdown.add(option);
  });

  // Add event listener to the dropdown
  industryDropdown.addEventListener("change", dropdownChange);
}

d3.csv("https://raw.githubusercontent.com/mohsinchougale/Job-Market-Analysis/main/hires_openings_jolts.csv", rowConverter)
  .then(function(data) {
    // Log loaded data to the console
    console.log(data);

    // Save data globally for easy access
    window.data = data;

    // Populate dropdown options
    populateDropdownOptions(data);

    // Initial chart render
    updateChart(data);
  })
  .catch(function(error) {
    // Handle errors
    console.error(error);
  });

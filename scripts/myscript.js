// Function to convert row data
function rowConverter(row) {
  return {
    industry_text: row.industry_text,
    year: +row.year,
    Hires: +row.Hires,
    JobOpenings: +row["Job openings"]
  };
}

// Function to populate dropdown options
function populateDropdownOptions(data) {
  const industryDropdown = d3.select("#industryDropdown");

  // Get unique industry values
  const uniqueIndustries = Array.from(new Set(data.map(d => d.industry_text)));

  // Populate dropdown with options
  industryDropdown
    .selectAll("option")
    .data(uniqueIndustries)
    .enter()
    .append("option")
    .text(d => d)
    .attr("value", d => d);
}

// Function to update the chart
function updateChart(data) {
  // Check if data is loaded
  if (!data || data.length === 0) {
    console.warn("No data available.");
    return;
  }

  // Select dropdown and buttons
  const industryDropdown = d3.select("#industryDropdown");
  const hiresButton = d3.select("#hiresButton");
  const openingsButton = d3.select("#openingsButton");

  // Initial selections
  let selectedIndustry = industryDropdown.property("value");
  let selectedDataType = hiresButton.classed("selected") ? "Hires" : "JobOpenings";

  // Filter data based on initial selections
  const filteredData = data.filter(
    d => d.industry_text === selectedIndustry && d[selectedDataType]
  );

  // Set up SVG container and scales
  const margin = { top: 20, right: 100, bottom: 60, left: 80 }; // Increased right margin
  const width = 800 - margin.left - margin.right; // Increased width
  const height = 500 - margin.top - margin.bottom; // Increased height

  const svg = d3
    .select("#plot")
    .html("") // Clear existing content
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  const xScale = d3
    .scaleLinear()
    .domain(d3.extent(filteredData, d => d.year))
    .range([0, width]);

  const yScale = d3
    .scaleLinear()
    .domain([0, d3.max(filteredData, d => d[selectedDataType])])
    .range([height, 0]);

  // Draw X-axis with all years
  svg
    .append("g")
    .attr("transform", "translate(0," + height + ")")
    .call(
      d3
        .axisBottom(xScale)
        .tickFormat(d3.format("d"))
        .ticks(filteredData.length) // Display all years
    )
    .selectAll("text")
    .style("text-anchor", "end")
    .attr("dx", "-.8em")
    .attr("dy", ".15em")
    .attr("transform", "rotate(-45)");

  // Draw Y-axis with a buffer on the left
  svg
    .append("g")
    .call(d3.axisLeft(yScale).ticks(11));

  // Label for X-axis
  svg
    .append("text")
    .attr("transform", "translate(" + width / 2 + " ," + (height + margin.top + 40) + ")")
    .style("text-anchor", "middle")
    .text("Year");

  // Label for Y-axis
  svg
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 0 - margin.left)
    .attr("x", 0 - height / 2)
    .attr("dy", "1em")
    .style("text-anchor", "middle")
    .text(selectedDataType);

  // Draw line and dots
  const line = d3
    .line()
    .x(d => xScale(d.year))
    .y(d => yScale(d[selectedDataType]));

  svg
    .append("path")
    .data([filteredData])
    .attr("fill", "none")
    .attr("stroke", "steelblue")
    .attr("stroke-width", 1.5)
    .attr("d", line);

  svg
    .selectAll("dot")
    .data(filteredData)
    .enter()
    .append("circle")
    .attr("r", 5)
    .attr("cx", d => xScale(d.year))
    .attr("cy", d => yScale(d[selectedDataType]));

  // Dropdown change event listener
  industryDropdown.on("change", function () {
    selectedIndustry = industryDropdown.property("value");
    updateChart(data);
  });

  // Button click event listeners
  hiresButton.on("click", function () {
    selectedDataType = "Hires";
    updateChart(data);
    updateButtonStyle(this);
  });

  openingsButton.on("click", function () {
    selectedDataType = "JobOpenings"; // Ensure correct data type
    updateChart(data);
    updateButtonStyle(this);
  });

  // Initial button styles
  updateButtonStyle(selectedDataType === "Hires" ? hiresButton.node() : openingsButton.node());
}

// Function to update button styles
function updateButtonStyle(selectedButton) {
  // Remove 'selected' class from all buttons
  d3.selectAll("button").classed("selected", false);

  // Add 'selected' class to the clicked button
  d3.select(selectedButton).classed("selected", true);
}

// Load data and initialize the chart
d3.csv("https://raw.githubusercontent.com/mohsinchougale/Job-Market-Analysis/main/hires_openings_jolts.csv", rowConverter)
  .then(function (data) {
    // Log loaded data to the console
    console.log(data);

    // Save data globally for easy access
    window.data = data;

    // Populate dropdown options
    populateDropdownOptions(data);

    // Initial chart render
    updateChart(data);
  })
  .catch(function (error) {
    // Handle errors
    console.error(error);
  });

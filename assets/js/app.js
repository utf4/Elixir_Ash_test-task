// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import mermaid from "mermaid";
import * as d3 from "d3";

//mermaid.initialize({startOnLoad:false, securityLevel: 'loose'})

const mermaidRender = (element, pushEvent) => {
	let inner = document.createElement("div");
	inner.id = "inner-" + element.id;
	inner.className = "mermaid max-h-full max-w-full";
	const insertSvg = function (svgCode, bindFunctions) {
		inner.innerHTML = svgCode;
		inner.querySelector("style").remove();
		inner.querySelector("svg").classList.add("h-full", "w-full");
		// add pushEvent to all nodes
		inner.querySelectorAll(".node").forEach((node) => {
			node.addEventListener("click", (e) => {
				pushEvent("node_click", { id: element.id, node: node.id });
			});
		});
		element.appendChild(inner);
	};
	mermaid.render(inner.id, element.dataset.mermaid, insertSvg);
};

let Hooks = {};
Hooks.Mermaid = {
	mounted() {
		let push = this.pushEvent.bind(this);
		mermaidRender(this.el, push);
	},
	updated() {
		let push = this.pushEvent.bind(this);
		mermaidRender(this.el, push);
	},
};

const scatterRender = (element, pushEvent) => {
	let rect = element.getBoundingClientRect();
	// set the dimensions and margins of the graph
	var margin = { top: 10, right: 30, bottom: 30, left: 60 },
		width = rect.width - margin.left - margin.right,
		height = rect.height - margin.top - margin.bottom;

	// append the svg object to the body of the page
	var svg = d3
		.select(element)
		.append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	//Read the data
	columns = JSON.parse(element.dataset.columns);

	// If the type of a column is "float" or "integer" use + to coerce
	data = d3.csvParse(element.dataset.csv, (row) =>
		Object.fromEntries(
			Object.entries(row).map(([k, v]) => {
				return [
					k,
					columns[k] === "float" || columns[k] === "integer" ? +v : v,
				];
			})
		)
	);

	xvar = element.dataset.xvar;
	yvar = element.dataset.yvar;

	// Add X axis
	var x = d3
		.scaleLinear()
		.domain(d3.extent(data, (d) => d[xvar]))
		.nice()
		.range([0, width]);
	svg.append("g")
		.attr("transform", "translate(0," + height + ")")
		.call(d3.axisBottom(x));

	// Add Y axis
	var y = d3
		.scaleLinear()
		.domain(d3.extent(data, (d) => d[yvar]))
		.nice()
		.range([0, width]);
	svg.append("g").call(d3.axisLeft(y));

	// Color scale: give me a specie name, I return a color
	var color = d3
		.scaleOrdinal()
		.domain(["setosa", "versicolor", "virginica"])
		.range(["#440154ff", "#21908dff", "#fde725ff"]);

	// Add dots
	var myCircle = svg
		.append("g")
		.selectAll("circle")
		.data(data)
		.enter()
		.append("circle")
		.attr("cx", function (d) {
			return x(d[xvar]);
		})
		.attr("cy", function (d) {
			return y(d[yvar]);
		})
		.attr("r", 8)
		.style("fill", function (d) {
			return color(d.Species);
		})
		.style("opacity", 0.5);

	// Add brushing
	svg.call(
		d3
			.brush() // Add the brush feature using the d3.brush function
			.extent([
				[0, 0],
				[width, height],
			]) // initialise the brush area: start at 0,0 and finishes at width,height: it means I select the whole graph area
			.on("start brush", updateChart) // Each time the brush selection changes, trigger the 'updateChart' function
	);

	// Function that is triggered when brushing is performed
	function updateChart() {
		extent = d3.event.selection;
		myCircle.classed("selected", function (d) {
			return isBrushed(extent, x(d[xvar]), y(d[yvar]));
		});
	}

	// A function that return TRUE or FALSE according if a dot is in the selection or not
	function isBrushed(brush_coords, cx, cy) {
		var x0 = brush_coords[0][0],
			x1 = brush_coords[1][0],
			y0 = brush_coords[0][1],
			y1 = brush_coords[1][1];
		return x0 <= cx && cx <= x1 && y0 <= cy && cy <= y1; // This return TRUE or FALSE depending on if the points is in the selected area
	}
};

Hooks.Scatter = {
	mounted() {
		push = this.pushEvent.bind(this);
		scatterRender(this.el, push);
	},
	updated() {
		push = this.pushEvent.bind(this);
		scatterRender(this.el, push);
	},
};

function hslToRgb(h, s, l) {
	if (s == 0) {
		const v = Math.round(l * 255);
		return [v, v, v];
	} else {
		const hue2rgb = (p, q, t) => {
			if (t < 0) t += 1;
			if (t > 1) t -= 1;
			if (t < 1 / 6) return p + (q - p) * 6 * t;
			if (t < 1 / 2) return q;
			if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
			return p;
		};

		const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
		const p = 2 * l - q;
		const r = Math.round(hue2rgb(p, q, h + 1 / 3) * 255);
		const g = Math.round(hue2rgb(p, q, h) * 255);
		const b = Math.round(hue2rgb(p, q, h - 1 / 3) * 255);
		return [r, g, b];
	}
}

const labelColors = Array.from({ length: 40 }, (_, i) => {
	const h = i / 40;
	return hslToRgb(h, 1, 0.6);
});

const sparseRender = (canvas, pushEvent) => {
	const m = canvas.dataset.m;
	const n = canvas.dataset.n;
	const arr = new Uint8ClampedArray(m * n * 4);
	const colptr = JSON.parse(canvas.dataset.colptr);
	const rowval = JSON.parse(canvas.dataset.rowval);
	const nzval = JSON.parse(canvas.dataset.nzval);

	for (let j = 0; j < colptr.length - 1; j++) {
		for (let k = colptr[j] - 1; k < colptr[j + 1] - 2; k++) {
			let i = rowval[k] - 1;
			let [r, g, b] = labelColors[(nzval[k] - 1) % labelColors.length];
			arr[4 * (j + i * n)] = r;
			arr[4 * (j + i * n) + 1] = g;
			arr[4 * (j + i * n) + 2] = b;
			arr[4 * (j + i * n) + 3] = 150;
		}
	}

	const data = new ImageData(arr, n, m);
	const ctx = canvas.getContext("2d");
	createImageBitmap(data).then((renderer) =>
		ctx.drawImage(renderer, 0, 0, canvas.width, canvas.height)
	);
};

Hooks.Sparse = {
	mounted() {
		push = this.pushEvent.bind(this);
		sparseRender(this.el, push);
	},
	updated() {
		push = this.pushEvent.bind(this);
		sparseRender(this.el, push);
	},
};

let csrfToken = document
	.querySelector("meta[name='csrf-token']")
	.getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
	params: { _csrf_token: csrfToken },
	hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) =>
	topbar.delayedShow(200)
);
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

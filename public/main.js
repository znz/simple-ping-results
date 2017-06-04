function drawResults(canvas_id, info_id, results) {
    const canvas = document.getElementById(canvas_id);
    const width = results.max - results.min + 1;
    const height = results.results.length;
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext("2d");
    const imageData = ctx.createImageData(width, height);
    const data = imageData.data;
    data[0] = 255; // R
    data[1] = 100; // G
    data[2] = 120; // B
    data[3] = 255; // A
    data[4+0] = 100; // R
    data[4+1] = 255; // G
    data[4+2] = 120; // B
    data[4+3] = 255; // A
    const array = new Uint32Array(data.buffer);
    const red = array[0];
    const green = array[1];
    for (let y = 0, i = 0; y<height; y++) {
	for (let x = 0; x<width; x++) {
	    if (results.results[y][1][x] === '1') {
		array[i] = green;
	    } else {
		array[i] = red;
	    }
	    i++;
	}
    }
    ctx.putImageData(imageData, 0, 0);

    canvas.onmousemove = e => {
	const info = document.getElementById(info_id);
	const X = e.offsetX < 0 ? 0 : width <= e.offsetX ? width-1 : e.offsetX;
	const Y = e.offsetY < 0 ? 0 : height <= e.offsetY ? height-1 : e.offsetY;
	const ip = results.range.replace(/x/, results.min + X);
	const timestamp = results.results[Y][0];
	let state, bg_class;
	const r = results.results[Y][1][X];
	if (r === '1') {
	    state = 'alive';
	    bg_class = 'alert alert-success';
	} else if (r === '0') {
	    state = 'unreachable';
	    bg_class = 'alert alert-danger';
	}
	info.innerHTML = `<p class="${bg_class}">${timestamp}: ${ip} is ${state}</p>`;
    };
    canvas.onmouseleave = e => {
	const info = document.getElementById(info_id);
	info.innerHTML = "";
    };
    canvas.onclick = e => {
	const X = e.offsetX < 0 ? 0 : width <= e.offsetX ? width : e.offsetX;
	location.href = `/ip/${results.range}/${results.min+X}/`;
    };
}

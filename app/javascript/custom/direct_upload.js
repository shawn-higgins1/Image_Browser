// Initiliaze the direct upload
addEventListener("direct-upload:initialize", event => {
    const { target, detail } = event
    const { id, file } = detail

    target.insertAdjacentHTML("beforebegin", `
        <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
            <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
        </div>
    `)

    // Create an image tag to preview the uploading images
    const img = document.createElement("img");
    img.setAttribute("width",50);
    img.setAttribute("height",50);
    img.file = file;
    $(`direct-upload-${id}`)[0].appendChild(img); // Assuming that "preview" is the div output where the content will be displayed.
    
    // Load a preview of the image to display while the files are uploading
    const reader = new FileReader();
    reader.onload = (function(aImg) { return function(e) { aImg.src = e.target.result; }; })(img);
    reader.readAsDataURL(file);
})
   
// Handle the beginning of uploading
addEventListener("direct-upload:start", event => {
    const { id } = event.detail
    const element = document.getElementById(`direct-upload-${id}`)
    element.classList.remove("direct-upload--pending")
})
   
// Update the UI with the upload progress
addEventListener("direct-upload:progress", event => {
    const { id, progress } = event.detail
    const progressElement = document.getElementById(`direct-upload-progress-${id}`)
    progressElement.style.width = `${progress}%`
})
   
// Event for when direct upload encounters an error
addEventListener("direct-upload:error", event => {
    event.preventDefault()
    const { id, error } = event.detail
    const element = document.getElementById(`direct-upload-${id}`)
    element.classList.add("direct-upload--error")
    element.setAttribute("title", error)
})
   
// Event for when direct upload ends
addEventListener("direct-upload:end", event => {
    const { id } = event.detail
    const element = document.getElementById(`direct-upload-${id}`)
    element.classList.add("direct-upload--complete")
})

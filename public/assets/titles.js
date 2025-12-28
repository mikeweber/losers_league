window.addEventListener("load", () => {
  const targetableElements = document.querySelectorAll("[popovertarget]")

  targetableElements.forEach((element) => {
    element.addEventListener("click", (e) => {
      const popoverId = e.target.getAttribute("popovertarget")
      const title = e.target.getAttribute("title")
      const popover = document.getElementById(popoverId)
      popover.textContent = title
      popover.togglePopover()
    })
  })
})

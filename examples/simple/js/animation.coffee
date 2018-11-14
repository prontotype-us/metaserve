title = document.getElementById('title')

repositionTitle = ->
    title.style.top = (Math.random()-0.5)*20
    title.style.left = (Math.random()-0.5)*50
    title.style.transform = "rotate(#{ (Math.random()-0.5)*20 }deg)"

    setTimeout repositionTitle, Math.random()*500+100

repositionTitle()


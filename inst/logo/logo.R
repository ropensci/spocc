# library(magick)
# urls=list(
#   bird="http://phylopic.org/assets/images/submissions/c961d79e-eeba-40c1-a4da-f93f22b264c7.128.png",
#   beetle="http://phylopic.org/assets/images/submissions/fbb67694-0fd2-4e90-b88d-efab9cbac37c.128.png",
#   rabbit="http://phylopic.org/assets/images/submissions/1e15411c-5394-4a9d-a209-76c8ac0c331d.128.png",
#   bee="http://phylopic.org/assets/images/submissions/070c78bc-e075-4098-a66b-fca2f02680ea.128.png"
# )
# bird <- image_read(urls$bird)
# beetle <- image_read(urls$beetle)
# rabbit <- image_read(urls$rabbit)
# bee <- image_read(urls$bee)
# z <- c(bird, image_scale(beetle, "x100+10+20"), bee)
# # z <- c(bird, beetle, bee)
# # imgs <- image_scale(z)
# # image_average(z)
# img <- image_average(z)
# img <- image_background(img, "none")
# image_write(img, "animals.png")
# image_mosaic(z)

library(hexSticker)
library(showtext)
font_add_google("Sedgwick Ave Display")
showtext_auto()

path_img <- "animals.png"
path_output <- "spocc.png"
sticker(path_img, package="spocc",
  p_x=1, p_y=1.5, p_size=12, p_family="Sedgwick Ave Display", p_color="#FFB188",
  s_x=1.1, s_y=0.8, s_width=1.2,
  h_color="#FFB188", h_fill="#D6D5D6",
  filename=path_output,
  url="images: phylopic.org", u_size = 1)

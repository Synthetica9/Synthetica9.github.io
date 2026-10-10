module Main where

import Extra
import qualified GHC.IO.Encoding as E
import Hakyll
import Hakyll.Web.Sass (sassCompiler)

data Link = Link {url :: String, desc :: String, relMe :: Bool}

links :: [Link]
links =
  [ Link "https://plasmatrap.com/@syn" "fedi" True,
    Link "https://github.com/synthetica9" "github" False,
    Link "https://codeberg.org/syn9" "codeberg" False,
    Link "https://last.fm/user/synthetica9" "last.fm" False,
    Link "https://listenbrainz.org/user/-syn/" "listenbrainz" False,
    Link "https://traewelling.de/@syn" "träwelling" False
  ]

-- TODO: FA icons or similar
renderLink :: Link -> String
renderLink link =
  "<a href=\""
    <> link.url
    <> "\" target=\"_blank\""
    <> mwhen link.relMe " rel=\"me\" "
    <> ">"
    <> escapeHtml link.desc
    <> "</a>"

linkBlock :: String
linkBlock =
  let aElems = renderLink <$> links
      liElems = (\x -> "<li>" <> x <> "</li>") <$> aElems
   in "<ul>" <> concat liElems <> "</ul>"

mainContext = constField "links" linkBlock <> defaultContext

main :: IO ()
main = do
  E.setLocaleEncoding E.utf8
  hakyll $ do
    -- TODO: sitemap: https://www.rohanjain.in/hakyll-sitemap/
    match "templates/*" $ compile templateCompiler

    match "css/*.sass" $ do
      route $ setExtension "css"
      let compressCssItem = fmap compressCss
      compile (compressCssItem <$> sassCompiler)

    match "pages/*.md" $ do
      route $ (gsubRoute "pages/" (const "")) `composeRoutes` setExtension "html"
      compile $
        pandocCompiler
          >>= loadAndApplyTemplate "templates/default.html" mainContext
          >>= relativizeUrls

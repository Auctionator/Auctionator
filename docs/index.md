layout: page
title: "Auctionator"
permalink: /

Follow the development status [here](https://github.com/Auctionator/Auctionator/projects/2).

Blizzard's revamp to the auction house broke virtually everything in the 8.2 Auctionator release, we are reimplementing features one by one. Asking repeatedly for a particular feature will not make it get implemented faster!

### Functional Features

#### Shopping Lists
All your old shopping lists still work, they're shown as a sidebar on the right of the Auction House "Buy" tab. Advanced search terms don't work [yet](https://github.com/Auctionator/Auctionator/issues/477).

![Shopping List Example]({{ site.url }}/images/shopping-list-example.png)

#### Autoscan
Unlike in the 8.2 Auction House it is now possible to scan for auction prices in the background when the AH is opened. You should see messages in your chat window indicating this is happening.

#### Tooltip prices
Auction and vendor prices are shown in item tooltips. Disenchant information isn't available [yet](https://github.com/Auctionator/Auctionator/issues/477).

#### Configuration
The configure UI for Auctionator is [currently broken](https://github.com/Auctionator/Auctionator/issues/480), until it is fixed configuration is done by chat commands.

Run `/auctionator config` to see available options.

Use the command `/auctionator config [option-name]` to turn an option on or off.

To reset your options use `/auctionator resetconfig`.

#### Upcoming Features
These are subject to change, and this is not an exhaustive list.

* [Fast cancelling undercut auctions](https://github.com/Auctionator/Auctionator/issues/476)
* [Undercut sale by a %](https://github.com/Auctionator/Auctionator/issues/475)
* [Advanced search syntax](https://github.com/Auctionator/Auctionator/issues/477)
* [Change the default auction duration](https://github.com/Auctionator/Auctionator/issues/481)
* [Historical scanned prices](https://github.com/Auctionator/Auctionator/issues/479)
* [Crafting reagent search](https://github.com/Auctionator/Auctionator/issues/484)
* [Translations into languages other than English](https://github.com/Auctionator/Auctionator/issues/490)

function thisBlobsBoundingBox = adjustBox (firstBoundingBox,thisBoundingBox)
    if(thisBoundingBox(1) < firstBoundingBox(1))
        firstBoundingBox(1) = thisBoundingBox(1);
    end
    if(thisBoundingBox(2) < firstBoundingBox(2))
        firstBoundingBox(2) = thisBoundingBox(2);
    end
    if(thisBoundingBox(3) > firstBoundingBox(3))
        firstBoundingBox(3) = thisBoundingBox(3);
    end
    if(thisBoundingBox(4) > firstBoundingBox(4))
        firstBoundingBox(4) = thisBoundingBox(4);
    end
  firstBoundingBox(1) = firstBoundingBox(1)-10;
  firstBoundingBox(2) = firstBoundingBox(2)-10;
  firstBoundingBox(3) = firstBoundingBox(3)+20;
  firstBoundingBox(4) = firstBoundingBox(4)+20;
    thisBlobsBoundingBox= firstBoundingBox;
end
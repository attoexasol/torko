import React from 'react';

interface MultiMediaGridProps {
  images?: string[];
  videos?: string[];
  onMediaClick?: (index: number) => void;
}

export const MultiMediaGrid: React.FC<MultiMediaGridProps> = ({ images, videos, onMediaClick }) => {
  const items = images || videos || [];
  const type = images ? 'image' : 'video';
  const count = items.length;

  const handleClick = (index: number, e: React.MouseEvent) => {
    // Don't trigger click if it's a video (let native controls work)
    if (type === 'video' && (e.target as HTMLElement).tagName === 'VIDEO') {
      return;
    }
    onMediaClick?.(index);
  };

  // Render different layouts based on count (Facebook style)
  const renderLayout = () => {
    switch (count) {
      case 1:
        // Single item - full width
        return (
          <div 
            className="overflow-hidden cursor-pointer"
            onClick={(e) => handleClick(0, e)}
          >
            {type === 'image' ? (
              <img 
                src={items[0]} 
                alt="Post content" 
                className="w-full h-auto object-cover"
                style={{ maxHeight: '500px' }}
              />
            ) : (
              <video 
                src={items[0]}
                controls
                className="w-full h-auto bg-black"
                style={{ maxHeight: '500px' }}
              />
            )}
          </div>
        );

      case 2:
        // Two items - side by side
        return (
          <div className="grid grid-cols-2 gap-[2px] overflow-hidden">
            {items.map((item, index) => (
              <div 
                key={index} 
                className="relative aspect-square overflow-hidden cursor-pointer"
                onClick={(e) => handleClick(index, e)}
              >
                {type === 'image' ? (
                  <img 
                    src={item} 
                    alt={`Post content ${index + 1}`}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <video 
                    src={item}
                    controls
                    className="w-full h-full object-cover bg-black"
                  />
                )}
              </div>
            ))}
          </div>
        );

      case 3:
        // Three items - First large on left, two stacked on right
        return (
          <div className="grid grid-cols-2 gap-[2px] overflow-hidden" style={{ height: '400px' }}>
            <div 
              className="relative row-span-2 overflow-hidden cursor-pointer"
              onClick={(e) => handleClick(0, e)}
            >
              {type === 'image' ? (
                <img 
                  src={items[0]} 
                  alt="Post content 1"
                  className="w-full h-full object-cover"
                />
              ) : (
                <video 
                  src={items[0]}
                  controls
                  className="w-full h-full object-cover bg-black"
                />
              )}
            </div>
            <div 
              className="relative overflow-hidden cursor-pointer"
              onClick={(e) => handleClick(1, e)}
            >
              {type === 'image' ? (
                <img 
                  src={items[1]} 
                  alt="Post content 2"
                  className="w-full h-full object-cover"
                />
              ) : (
                <video 
                  src={items[1]}
                  controls
                  className="w-full h-full object-cover bg-black"
                />
              )}
            </div>
            <div 
              className="relative overflow-hidden cursor-pointer"
              onClick={(e) => handleClick(2, e)}
            >
              {type === 'image' ? (
                <img 
                  src={items[2]} 
                  alt="Post content 3"
                  className="w-full h-full object-cover"
                />
              ) : (
                <video 
                  src={items[2]}
                  controls
                  className="w-full h-full object-cover bg-black"
                />
              )}
            </div>
          </div>
        );

      case 4:
        // Four items - 2x2 grid
        return (
          <div className="grid grid-cols-2 gap-[2px] overflow-hidden">
            {items.map((item, index) => (
              <div 
                key={index} 
                className="relative aspect-square overflow-hidden cursor-pointer"
                onClick={(e) => handleClick(index, e)}
              >
                {type === 'image' ? (
                  <img 
                    src={item} 
                    alt={`Post content ${index + 1}`}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <video 
                    src={item}
                    controls
                    className="w-full h-full object-cover bg-black"
                  />
                )}
              </div>
            ))}
          </div>
        );

      case 5:
        // Five items - 2 on top, 3 on bottom
        return (
          <div className="overflow-hidden">
            <div className="grid grid-cols-2 gap-[2px]">
              {items.slice(0, 2).map((item, index) => (
                <div 
                  key={index} 
                  className="relative aspect-square overflow-hidden cursor-pointer"
                  onClick={(e) => handleClick(index, e)}
                >
                  {type === 'image' ? (
                    <img 
                      src={item} 
                      alt={`Post content ${index + 1}`}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <video 
                      src={item}
                      controls
                      className="w-full h-full object-cover bg-black"
                    />
                  )}
                </div>
              ))}
            </div>
            <div className="grid grid-cols-3 gap-[2px] mt-[2px]">
              {items.slice(2, 5).map((item, index) => (
                <div 
                  key={index + 2} 
                  className="relative aspect-square overflow-hidden cursor-pointer"
                  onClick={(e) => handleClick(index + 2, e)}
                >
                  {type === 'image' ? (
                    <img 
                      src={item} 
                      alt={`Post content ${index + 3}`}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <video 
                      src={item}
                      controls
                      className="w-full h-full object-cover bg-black"
                    />
                  )}
                </div>
              ))}
            </div>
          </div>
        );

      default:
        // 6+ items - Show 5 with "+X more" overlay on last
        const remaining = count - 5;
        return (
          <div className="overflow-hidden">
            <div className="grid grid-cols-2 gap-[2px]">
              {items.slice(0, 2).map((item, index) => (
                <div 
                  key={index} 
                  className="relative aspect-square overflow-hidden cursor-pointer"
                  onClick={(e) => handleClick(index, e)}
                >
                  {type === 'image' ? (
                    <img 
                      src={item} 
                      alt={`Post content ${index + 1}`}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <video 
                      src={item}
                      controls
                      className="w-full h-full object-cover bg-black"
                    />
                  )}
                </div>
              ))}
            </div>
            <div className="grid grid-cols-3 gap-[2px] mt-[2px]">
              {items.slice(2, 5).map((item, index) => (
                <div 
                  key={index + 2} 
                  className="relative aspect-square overflow-hidden cursor-pointer"
                  onClick={(e) => handleClick(index + 2, e)}
                >
                  {type === 'image' ? (
                    <img 
                      src={item} 
                      alt={`Post content ${index + 3}`}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <video 
                      src={item}
                      controls
                      className="w-full h-full object-cover bg-black"
                    />
                  )}
                  {/* Show "+X more" overlay on last item */}
                  {index === 2 && remaining > 0 && (
                    <div className="absolute inset-0 bg-black/60 flex items-center justify-center pointer-events-none">
                      <span 
                        className="text-white"
                        style={{
                          fontSize: '32px',
                          fontWeight: '700'
                        }}
                      >
                        +{remaining}
                      </span>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        );
    }
  };

  return <div className="mt-[12px]">{renderLayout()}</div>;
};
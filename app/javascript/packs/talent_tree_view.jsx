import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

import {AutoSizer} from 'react-virtualized'
import {ReactSVGPanZoom} from 'react-svg-pan-zoom';

class TalentTreeContainer extends React.Component {
  constructor(props) {
    super(props);

    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseMove = this.handleMouseMove.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);
  }

  // Talent tree pan start
  handleMouseDown(e) {
    if (e.originalEvent.button == 1) {
      this.mouseX = e.originalEvent.pageX;
      this.mouseY = e.originalEvent.pageY;
      window.talentTreePan = true;
    }
  }

  // Talent tree pan
  handleMouseMove(e) {
    if (window.talentTreePan) {
      var dx = (e.originalEvent.pageX - this.mouseX) / e.scaleFactor;
      var dy = (e.originalEvent.pageY - this.mouseY) / e.scaleFactor;
      this.Viewer.pan(dx, dy);
      this.mouseX = e.originalEvent.pageX;
      this.mouseY = e.originalEvent.pageY;
    }
  }

  // Talent tree pan end
  handleMouseUp(e) {
    if (e.originalEvent.button == 1) {
      window.talentTreePan = false;
    }
  }

  render() {
    return (
      <AutoSizer>
        {(({width, height}) => width === 0 || height === 0 ? null : (
          <ReactSVGPanZoom width={width} height={height} detectAutoPan={false} onZoom={this.handleZoom}
                           onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp}
                           onMouseMove={this.handleMouseMove} ref={Viewer => this.Viewer = Viewer}>
            <svg width={this.props.tree.width} height={this.props.tree.height}>
              <TalentTree tree={this.props.tree} defaultBg={this.props.defaultBg} />
            </svg>
          </ReactSVGPanZoom>
        ))}
      </AutoSizer>
    );
  }
}

class TalentTree extends React.Component {
  render() {
    const {width, height, talent_size, image} = this.props.tree
    const talents = this.props.tree.talent_tree_talents.map((talent) =>
      <Talent x={talent.pos_x} y={talent.pos_y} size={talent_size}
              talent={talent.talent} unlocked={talent.unlocked} treeId={this.props.tree.id}
              id={talent.id} key={talent.id} />
    );

    const bgUrl = image ? (
      image
    ) : (
      this.props.defaultBg
    );

    return (
      <g>
        <defs>
          <pattern id="backdrop" x={0} y={0} height="100%" width="100%"
                   patternContentUnits="objectBoundingBox">
            <image height={1} width={1} preserveAspectRatio="none"
                   xlinkHref={bgUrl} />
          </pattern>
        </defs>
        <rect x={0} y={0} width={width} height={height}
              fill='url(#backdrop)' />
        {talents}
      </g>
    );
  }
}

class Talent extends React.Component {
  render() {
    const {x, y, size, talent, unlocked} = this.props;
    const points = unlocked ? talent.points : 0;
    const questsPath = "/user/quests?groups=t" + talent.id;

    // Generate talent content popover
    var content = '<p class="mb-2">' + talent.description + '</p>' +
      '<ul class="list-group">';
    for (var i = 0; i < talent.talent_attributes.length; i++) {
      const attr = talent.talent_attributes[i];
      if (attr.points !== null && attr.points > 0) {
        content += '<li class="list-group-item">' +
          '+ ' + attr.points + ' ' +
          attr.character_attribute.name +
          '</li>';
      }
    }
    content += '</ul>';

    const bgUrl = "url(#talent" + this.props.id + ")";
    const bg = talent.image ? (
      <svg>
        <defs>
          <pattern id={"talent" + this.props.id} x={0} y={0} height="100%" width="100%"
                   patternContentUnits="objectBoundingBox">
            <image height={1} width={1} preserveAspectRatio="none"
              xlinkHref={talent.image} />
          </pattern>
        </defs>
        <rect x={x} y={y} width={size} height={size}
              style={{fill: bgUrl, stroke: 'black', strokeWidth: '0.2em'}}
              data-toggle="popover" data-container="body" data-html="true"
              title={talent.name + ' (' + points + '/' + talent.points + ')'}
              data-content={content} data-placement="auto"
              data-trigger="click hover" />
      </svg>
    ) : (
      <rect x={x} y={y} width={size} height={size}
            style={{fill: '#c0c7ea', stroke: 'black', strokeWidth: '0.2em'}}
            data-toggle="popover" data-container="body" data-html="true"
            title={talent.name + ' (' + points + '/' + talent.points + ')'}
            data-content={content} data-placement="auto"
            data-trigger="click hover" />
    );

    return (
      <g className="talent" style={{opacity: unlocked ? 1 : 0.5}}>
        {bg}
        <svg x={x} y={y} width={size} height={size} style={{pointerEvents: 'none'}}>
          <text x='50%' y='55%' alignmentBaseline="middle" textAnchor="middle"
                style={{fontSize: size / 4.5}}>{talent.code}</text>
        </svg>
        <svg x={x} y={y} width={size} height={size}>
          <a xlinkHref={questsPath}>
            <text x='90%' y='90%' dominantBaseline="baseline" textAnchor="end"
                  style={{fontSize: size / 4.5, fill: '#6c757d'}}>&#xf08e;<title>Přejít k úkolům</title></text>
          </a>
        </svg>
      </g>
    );
  }
}

document.addEventListener('DOMContentLoaded', () => {
  // <a><text/></a> Rails error on obtaining href workaround
  SVGAnimatedString.prototype.toString = function () { return this.baseVal; }

  const container = document.getElementById('talent-tree');
  const tree = JSON.parse(container.getAttribute('data-talent-tree'));
  const defaultBg = container.getAttribute('data-default-bg');

  ReactDOM.render(
    <TalentTreeContainer tree={tree} defaultBg={defaultBg} />,
    container
  )
})

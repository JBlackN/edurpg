import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

import {AutoSizer} from 'react-virtualized'
import {ReactSVGPanZoom} from 'react-svg-pan-zoom';

class TalentTreeContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      scale: 1.0
    };

    this.handleZoom = this.handleZoom.bind(this);
  }

  handleZoom(scale) {
    this.setState(prevState => ({
      scale: scale.a
    }));
  };

  render() {
    return (
      <AutoSizer>
        {(({width, height}) => width === 0 || height === 0 ? null : (
          <ReactSVGPanZoom width={width} height={height} detectAutoPan={false} onZoom={this.handleZoom}>
            <svg width={this.props.tree.width} height={this.props.tree.height}>
              <TalentTree tree={this.props.tree} scale={this.state.scale} />
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
              scale={this.props.scale} id={talent.id} key={talent.id} />
    );

    const bgUrl = image ? (
      "data:image/png;base64," + image
    ) : (
      "https://i.imgur.com/4KeO1m5.jpg"
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
              xlinkHref={"data:image/png;base64," + talent.image} />
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
            style={{fill: 'pink', stroke: 'black', strokeWidth: '0.2em'}}
            data-toggle="popover" data-container="body" data-html="true"
            title={talent.name + ' (' + points + '/' + talent.points + ')'}
            data-content={content} data-placement="auto"
            data-trigger="click hover" />
    );

    return (
      <g className="talent" style={{opacity: unlocked ? 1 : 0.33}}>
        {bg}
        <svg x={x} y={y} width={size} height={size} style={{pointerEvents: 'none'}}>
          <text x='50%' y='55%' alignmentBaseline="middle" textAnchor="middle"
                style={{fontSize: '0.67em'}}>{talent.code}</text>
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

  ReactDOM.render(
    <TalentTreeContainer tree={tree} />,
    container
  )
})

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
  constructor(props) {
    super(props);
  }

  componentDidMount() {
    const talentTreeForm = document.getElementById('talent-tree-form');
    talentTreeForm.addEventListener('submit', this.handleFormSubmit);
  }

  componentWillUnmount() {
    const talentTreeForm = document.getElementById('talent-tree-form');
    talentTreeForm.removeEventListener('submit', this.handleFormSubmit);
  }

  handleFormSubmit() {
    const talentTreeForm = document.getElementById('talent-tree-form');
    var input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'talent_tree[test]'
    input.value = 'test';
    talentTreeForm.appendChild(input);
  }

  render() {
    const {width, height, talent_size} = this.props.tree
    const talents = this.props.tree.talent_tree_talents.map((talent) =>
      <Talent x={talent.pos_x} y={talent.pos_y} size={talent_size} talent={talent.talent}
              scale={this.props.scale} key={talent.id} />
    );

    return (
      <g>
        <defs>
          <pattern id="backdrop" x={0} y={0} height="100%" width="100%"
                   patternContentUnits="objectBoundingBox">
            <image height={1} width={1} preserveAspectRatio="none"
                   xlinkHref="https://i.imgur.com/4KeO1m5.jpg" />
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
  constructor(props) {
    super(props);
    this.state = {
      x: this.props.x,
      y: this.props.y,
      size: this.props.size
    };

    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseMove = this.handleMouseMove.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);
    this.handleDragStart = this.handleDragStart.bind(this);
  }

  handleMouseDown(e) {
    this.mouseX = e.pageX;
    this.mouseY = e.pageY;
    this.startX = this.state.x
    this.startY = this.state.y
    document.addEventListener('mousemove', this.handleMouseMove);
  }

  handleMouseMove(e) {
    e.preventDefault();
    var dx = (e.pageX - this.mouseX) / this.props.scale;
    var dy = (e.pageY - this.mouseY) / this.props.scale;

    this.setState(prevState => ({
      x: this.startX + dx,
      y: this.startY + dy
    }));
  }

  handleMouseUp() {
    document.removeEventListener('mousemove', this.handleMouseMove);
  }

  handleDragStart(e) {
    e.preventDefault();
  }

  render() {
    const {x, y, size} = this.state
    const {talent} = this.props

    return (
      <g onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp}
         onDragStart={this.handleDragStart} className="talent">
        <rect x={x} y={y} width={size} height={size}
              style={{fill: 'pink', stroke: 'black', strokeWidth: '0.2em'}} />
        <svg x={x} y={y} width={size} height={size}>
          <text x='50%' y='55%' alignmentBaseline="middle" textAnchor="middle"
                style={{fontSize: '0.67em'}}>{talent.code}</text>
        </svg>
      </g>
    );
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('talent-tree');
  const tree = JSON.parse(container.getAttribute('data-talent-tree'));

  ReactDOM.render(
    <TalentTreeContainer tree={tree} />,
    container
  )
})

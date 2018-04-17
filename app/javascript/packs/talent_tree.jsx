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
    this.state = {};
    for (var i = 0; i < this.props.tree.talent_tree_talents.length; i++) {
      const talent_tree_talent = this.props.tree.talent_tree_talents[i];
      this.state[talent_tree_talent.id] = {
        x: talent_tree_talent.pos_x,
        y: talent_tree_talent.pos_y
      };
    }

    this.handleMoveStart = this.handleMoveStart.bind(this);
    this.handleMove = this.handleMove.bind(this);
    this.handleMoveEnd = this.handleMoveEnd.bind(this);
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  componentDidMount() {
    if (!window.formSubmitAttached) {
      const talentTreeForm = document.getElementById('talent-tree-form');
      talentTreeForm.addEventListener('submit', this.handleFormSubmit);
    }
    window.formSubmitAttached = true;
  }

  componentWillUnmount() {
    const talentTreeForm = document.getElementById('talent-tree-form');
    talentTreeForm.removeEventListener('submit', this.handleFormSubmit);
  }

  handleFormSubmit(e) {
    const talentTreeForm = document.getElementById('talent-tree-form');
    for (var id in this.state) {
      const {x, y} = this.state[id];
      var inputX = document.createElement('input');
      var inputY = document.createElement('input');

      inputX.type = 'hidden';
      inputX.name = 'talent_tree[positions][' + id + '][x]';
      inputX.value = x;

      inputY.type = 'hidden';
      inputY.name = 'talent_tree[positions][' + id + '][y]';
      inputY.value = y;

      talentTreeForm.appendChild(inputX);
      talentTreeForm.appendChild(inputY);
    }
  }

  handleMoveStart(e, id) {
    this.mouseX = e.pageX;
    this.mouseY = e.pageY;
    this.startX = this.state[id].x;
    this.startY = this.state[id].y;
    this.movingId = id;

    document.addEventListener('mousemove', this.handleMove);
  }

  handleMove(e, id) {
    e.preventDefault();
    var dx = (e.pageX - this.mouseX) / this.props.scale;
    var dy = (e.pageY - this.mouseY) / this.props.scale;

    var state = this.state
    state[this.movingId].x = this.startX + dx;
    state[this.movingId].y = this.startY + dy;

    this.setState(prevState => (state));
  }

  handleMoveEnd() {
    document.removeEventListener('mousemove', this.handleMove);
  }

  render() {
    const {width, height, talent_size} = this.props.tree
    const talents = this.props.tree.talent_tree_talents.map((talent) =>
      <Talent x={this.state[talent.id].x} y={this.state[talent.id].y}
              size={talent_size} talent={talent.talent} treeId={this.props.tree.id}
              onMouseDown={this.handleMoveStart} onMouseUp={this.handleMoveEnd}
              onMouseMove={this.handleMove}
              scale={this.props.scale} id={talent.id} key={talent.id} />
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
    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseMove = this.handleMouseMove.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);
    this.handleDragStart = this.handleDragStart.bind(this);
  }

  handleMouseDown(e) {
    this.props.onMouseDown(e, this.props.id);
  }

  handleMouseMove(e) {
    e.preventDefault();
    this.props.onMouseMove(e, this.props.id);
  }

  handleMouseUp() {
    this.props.onMouseUp();
  }

  handleDragStart(e) {
    e.preventDefault();
  }

  render() {
    const {x, y, size, talent} = this.props;
    const deletePath = "/admin/talent_trees/" + this.props.treeId + "/talents/" + this.props.id;
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
              style={{fill: bgUrl, stroke: 'black', strokeWidth: '0.2em'}} />
      </svg>
    ) : (
      <rect x={x} y={y} width={size} height={size}
            style={{fill: 'pink', stroke: 'black', strokeWidth: '0.2em'}} />
    );

    return (
      <g onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp}
         onDragStart={this.handleDragStart} className="talent">
        {bg}
        <svg x={x} y={y} width={size} height={size}>
          <text x='50%' y='55%' alignmentBaseline="middle" textAnchor="middle"
                style={{fontSize: '0.67em'}}>{talent.code}</text>
        </svg>
        <svg x={x} y={y} width={size} height={size}>
          <a xlinkHref={deletePath}
             data-confirm="Neuložené změny budou ztraceny. Smazat talent?"
             data-method="delete" rel="nofollow">
            <text x='90%' y='2%' dominantBaseline="hanging" textAnchor="end"
                  style={{fontSize: '0.67em', fontWeight: 'bold'}}>X</text>
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

  ReactDOM.render(
    <TalentTreeContainer tree={tree} />,
    container
  )
})
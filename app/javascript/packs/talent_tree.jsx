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
    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseMove = this.handleMouseMove.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);
  }

  handleZoom(scale) {
    this.setState(prevState => ({
      scale: scale.a
    }));
  }

  handleMouseDown(e) {
    if (e.originalEvent.button == 1) {
      this.mouseX = e.originalEvent.pageX;
      this.mouseY = e.originalEvent.pageY;
      window.talentTreePan = true;
    }
  }

  handleMouseMove(e) {
    if (window.talentTreePan) {
      var dx = (e.originalEvent.pageX - this.mouseX) / e.scaleFactor;
      var dy = (e.originalEvent.pageY - this.mouseY) / e.scaleFactor;
      this.Viewer.pan(dx, dy);
      this.mouseX = e.originalEvent.pageX;
      this.mouseY = e.originalEvent.pageY;
    }
  }

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
              <TalentTree tree={this.props.tree} scale={this.state.scale} defaultBg={this.props.defaultBg} />
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
    window.unsavedChanges = false;
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

    if (e.button == 0) {
      document.addEventListener('mousemove', this.handleMove);
    }
  }

  handleMove(e, id) {
    e.preventDefault();
    var dx = (e.pageX - this.mouseX) / this.props.scale;
    var dy = (e.pageY - this.mouseY) / this.props.scale;

    var state = this.state
    state[this.movingId].x = this.startX + dx;
    state[this.movingId].y = this.startY + dy;

    this.setState(prevState => (state));
    if (!window.unsavedChanges) window.unsavedChanges = true;
  }

  handleMoveEnd(e) {
    if (e.button == 0) {
      document.removeEventListener('mousemove', this.handleMove);
    }
  }

  render() {
    const {width, height, talent_size, image} = this.props.tree
    const talents = this.props.tree.talent_tree_talents.map((talent) =>
      <Talent x={this.state[talent.id].x} y={this.state[talent.id].y}
              size={talent_size} talent={talent.talent} tree={this.props.tree}
              onMouseDown={this.handleMoveStart} onMouseUp={this.handleMoveEnd}
              onMouseMove={this.handleMove}
              scale={this.props.scale} id={talent.id} key={talent.id} />
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

  handleMouseUp(e) {
    this.props.onMouseUp(e);
  }

  handleDragStart(e) {
    e.preventDefault();
  }

  render() {
    const {x, y, size, tree, talent, id} = this.props;
    const namespace = tree.character_id ? 'user' : 'admin';
    const updatePath = "/" + namespace + "/talent_trees/" + tree.id + "/talents/" + id + "/edit";
    const deletePath = "/" + namespace + "/talent_trees/" + tree.id + "/talents/" + id;
    const questsPath = "/" + namespace + "/quests?groups=t" + talent.id;

    const bgUrl = "url(#talent" + id + ")";
    const bg = talent.image ? (
      <svg>
        <defs>
          <pattern id={"talent" + id} x={0} y={0} height="100%" width="100%"
                   patternContentUnits="objectBoundingBox">
            <image height={1} width={1} preserveAspectRatio="none"
              xlinkHref={talent.image} />
          </pattern>
        </defs>
        <rect x={x} y={y} width={size} height={size}
              style={{fill: bgUrl, stroke: 'black', strokeWidth: '0.2em'}} />
      </svg>
    ) : (
      <rect x={x} y={y} width={size} height={size}
            style={{fill: '#c0c7ea', stroke: 'black', strokeWidth: '0.2em'}} />
    );

    return (
      <g onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp}
         onDragStart={this.handleDragStart} className="talent">
        {bg}
        <svg x={x} y={y} width={size} height={size}>
          <text x='50%' y='55%' alignmentBaseline="middle" textAnchor="middle"
                style={{fontSize: size / 4.5}}>{talent.code}</text>
        </svg>
        <svg x={x} y={y} width={size} height={size}>
          <a xlinkHref={updatePath} className="watch-unsaved">
            <text x='10%' y='5%' dominantBaseline="hanging" textAnchor="start"
                  style={{fontSize: size / 4.5, fontWeight: 'bold'}}>&#xf044;<title>Upravit talent</title></text>
          </a>
          <a xlinkHref={deletePath} className="watch-unsaved" data-method="delete" rel="nofollow"
             data-confirm="Odstranit talent?">
            <text x='90%' y='4%' dominantBaseline="hanging" textAnchor="end"
                  style={{fontSize: size / 4.5, fontWeight: 'bold'}}>&#xf00d;<title>Odstranit talent</title></text>
          </a>
          <a xlinkHref={questsPath} className="watch-unsaved">
            <text x='90%' y='90%' dominantBaseline="baseline" textAnchor="end"
                  style={{fontSize: size / 4.5, fill: '#6c757d'}}>&#xf061;<title>Přejít k úkolům</title></text>
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
